//
//  AuthManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import SwiftyBeaver
import ATProtoKit
import KeychainSwift

@MainActor
@Observable
// MARK: - MANAGER
public final class AuthManager: @unchecked Sendable {
    //MARK: - PROPERTIES
    let keychain = KeychainSwift()
    let ATProtoKeychain: AppleSecureKeychain
    
    public private(set) var clientManager: ClientManager?
    public private(set) var configState: ConfigState = .empty
    
    public let clientManagerContinuation: AsyncStream<ClientManager?>.Continuation
    public let clientManagerUpdates: AsyncStream<ClientManager?>
    
    // Keep ONE config alive across the whole 2FA flow
    private var pendingConfig: ATProtocolConfiguration?
    private var signInTask: Task<Void, Never>?
    
    public enum ConfigState { case restored, unauthorized, failed, empty }
    
    public init() {
        log.info("Initializing authentication manager")
        var initConfigState: ConfigState = .empty
        
        if let uuid = keychain.get("session_uuid"), let realUUID = UUID(uuidString: uuid) {
            log.debug("Found existing session UUID: \(uuid)")
            self.ATProtoKeychain = AppleSecureKeychain(identifier: realUUID)
        } else {
            let newUUID = UUID().uuidString
            log.debug("Creating new session UUID: \(newUUID)")
            guard keychain.set(newUUID, forKey: "session_uuid"),
                  let realUUID = UUID(uuidString: newUUID) else {
                log.error("Failed to create or store session_uuid")
                hapticFeedback(.error)
                initConfigState = .empty
                // Initializers cannot throw, so we use preconditionFailure here
                preconditionFailure("Authentication Manager: Failed to create or store session_uuid.")
            }
            self.ATProtoKeychain = AppleSecureKeychain(identifier: realUUID)
            log.info("Successfully created and stored new session UUID")
        }
        
        let (stream, continuation) = AsyncStream<ClientManager?>.makeStream(bufferingPolicy: .bufferingNewest(1))
        self.clientManagerUpdates = stream
        self.clientManagerContinuation = continuation
        
        self.configState = initConfigState
        log.info("Initialization complete, starting session restore")
        
        Task { await restoreSession() }
    }
    
    /// Start sign-in and let ATProtoKit block internally waiting for code via codeStream.
    /// Throws AuthError.operationInProgress if a sign-in is already running.
    /// Throws AuthError.authenticationFailed on failure.
    public func startSignIn(pdsURL: String, handle: String, password: String) async throws {
        // Don't kick off another attempt if one is already running.
        guard signInTask == nil else {
            log.warning("Attempted to start sign-in while another attempt is already running")
            throw AuthError.operationInProgress
        }
        
        log.info("Starting sign-in process for handle: \(handle)")
        log.debug("Using PDS URL: \(pdsURL)")
        
        let config = ATProtocolConfiguration(pdsURL: pdsURL, keychainProtocol: ATProtoKeychain)
        self.pendingConfig = config
        
        // Set state to unauthorized immediately when 2FA is expected
        configState = .unauthorized
        log.debug("Set config state to unauthorized, awaiting authentication")
        
        // Run authenticate in the background; it will suspend on 2FA until we yield a code.
        signInTask = Task { [weak self] in
            do {
                log.debug("Beginning authentication process")
                try await config.authenticate(with: handle, password: password)
                log.info("Authentication successful")
                
                await self?.setClientManager(with: config)
                await MainActor.run {
                    self?.configState = .restored
                    self?.pendingConfig = nil
                    self?.signInTask = nil
                }
                log.info("Sign-in process completed successfully")
            } catch {
                log.error("Authentication failed with error: \(error.localizedDescription)")
                await MainActor.run {
                    self?.configState = .failed
                    self?.pendingConfig = nil
                    self?.signInTask = nil
                }
                self?.clientManagerContinuation.yield(nil)
            }
        }
    }
    
    /// Feed the user's 2FA code into the SAME config that started authenticate()
    public func submitTwoFactorCode(_ code: String) {
        guard let config = pendingConfig else {
            log.warning("submitTwoFactorCode called with no pending config; ignoring")
            return
        }
        log.debug("Submitting two-factor authentication code")
        config.receiveCodeFromUser(code)
    }
    
    /// Allow canceling the in-flight attempt if user backs out
    public func cancelPendingSignIn() {
        log.info("Canceling pending sign-in attempt")
        signInTask?.cancel()
        signInTask = nil
        pendingConfig = nil
        log.debug("Pending sign-in attempt canceled successfully")
    }
}

// MARK: - METHODS
extension AuthManager {
    // MARK: - AUTHENTICATE
    // Legacy or direct authentication without 2FA
    private func authenticateWith(handle: String, password: String, authFactorToken: String? = nil) async throws -> ATProtocolConfiguration {
        log.debug("Authenticating with handle: \(handle)")
        let config = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
        do {
            try await config.authenticate(with: handle, password: password)
            log.info("Direct authentication successful")
            return config
        } catch {
            log.error("Direct authentication failed: \(error.localizedDescription)")
            throw AuthError.authenticationFailed(error)
        }
    }
    
    // MARK: - CREATE ACCOUNT
    /// Updated: Fix for ATProtoKit registration. Use ATProtoKit's client to create account instead of non-existent config.register.
    /// Throws AuthError.accountCreationFailed or AuthError.invalidCredentials if registration or authentication fails.
    /// After registration, proceed to authenticate and set up session as normal.
    public func createAccount(handle: String, password: String) async throws -> Bool {
        log.info("Creating new account for handle: \(handle)")
        
        do {
            let config = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
            let atproto = await ATProtoKit(sessionConfiguration: config)
            _ = try await atproto.createAccount(handle: handle, password: password)
            log.info("Account creation successful, proceeding to authenticate")
            
            let authenticatedConfig = try await authenticateWith(handle: handle, password: password)
            await setClientManager(with: authenticatedConfig)
            withAnimation(Animation.snappy(duration: 1.5)) {
                self.configState = .restored
            }
            log.info("Account creation and authentication process completed successfully")
            return false
        } catch let error as AuthError {
            // Re-throw AuthErrors as is
            throw error
        } catch {
            log.error("Account creation failed: \(error.localizedDescription)")
            if (error.localizedDescription.contains("invalid") || error.localizedDescription.contains("credential")) {
                throw AuthError.invalidCredentials
            } else {
                throw AuthError.accountCreationFailed(error)
            }
        }
    }
    
    // MARK: - LOG OUT
    /// Throws AuthError.signOutFailed if logout fails.
    public func logout() async throws {
        log.info("Starting logout process")
        do {
            try await logoutWith(config: clientManager?.credentials)
            self.clientManager = nil
            clientManagerContinuation.yield(nil)
            self.configState = .failed
            log.info("Logout completed successfully")
        } catch {
            log.error("Logout failed: \(error.localizedDescription)")
            throw AuthError.signOutFailed(error)
        }
    }
    
    // MARK: - REFRESH
    /// Refresh current session.
    /// Catches errors and updates state accordingly.
    public func refresh() async {
        log.debug("Starting session refresh")
        do {
            let config = try await refreshSession()
            await setClientManager(with: config)
            self.configState = .restored
            log.info("Session refresh successful")
        } catch {
            log.error("Session refresh failed: \(error.localizedDescription)")
            self.clientManager = nil
            clientManagerContinuation.yield(nil)
            self.configState = .failed
        }
    }
    
    // MARK: - RESTORE SESSION
    /// Attempt to restore session on startup.
    /// Handles failures by purging invalid tokens and updating state.
    public func restoreSession() async {
        log.debug("Attempting to restore session")
        do {
            let config = try await refreshSession()
            await setClientManager(with: config)
            await MainActor.run { self.configState = .restored }
            log.info("Session restored successfully")
        } catch {
            log.warning("Session restore failed: \(error.localizedDescription)")
            // Optionally purge invalid tokens
            do {
                try await clientManager?.credentials.deleteSession()
                log.debug("Invalid session tokens purged")
            } catch {
                log.error("Failed to purge invalid tokens: \(error.localizedDescription)")
            }
            
            await MainActor.run {
                self.clientManager = nil
                clientManagerContinuation.yield(nil)
                self.configState = .failed
            }
        }
    }
    
    // MARK: - HELPER METHODS
    private func setClientManager(with config: ATProtocolConfiguration) async {
        log.debug("Setting up client manager with authenticated configuration")
        let manager = await ClientManager(credentials: config)
        self.clientManager = manager
        clientManagerContinuation.yield(manager)
        log.debug("Client manager setup complete")
    }
    
    private func refreshSession() async throws -> ATProtocolConfiguration {
        log.debug("Refreshing session configuration")
        let config = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
        do {
            try await config.refreshSession()
            log.debug("Session configuration refresh successful")
            return config
        } catch {
            log.error("Session configuration refresh failed: \(error.localizedDescription)")
            throw AuthError.sessionRefreshFailed(error)
        }
    }
    
    private func logoutWith(config: ATProtocolConfiguration?) async throws {
        log.debug("Deleting session from configuration")
        do {
            try await config?.deleteSession()
            log.debug("Session deletion successful")
        } catch {
            log.error("Session deletion failed: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - ERRORS
public enum AuthError: LocalizedError, Equatable {
    case operationInProgress
    case authenticationFailed(Error)
    case accountCreationFailed(Error)
    case signOutFailed(Error)
    case sessionRefreshFailed(Error)
    case keychainSetupFailed
    case invalidCredentials
    
    public var errorDescription: String? {
        switch self {
        case .operationInProgress:
            return "Another authentication operation is already in progress"
        case .authenticationFailed(let error):
            return "Authentication failed: \(error.localizedDescription)"
        case .accountCreationFailed(let error):
            return "Account creation failed: \(error.localizedDescription)"
        case .signOutFailed(let error):
            return "Sign out failed: \(error.localizedDescription)"
        case .sessionRefreshFailed(let error):
            return "Session refresh failed: \(error.localizedDescription)"
        case .keychainSetupFailed:
            return "Failed to setup keychain for secure storage"
        case .invalidCredentials:
            return "Invalid credentials provided"
        }
    }
    
    public static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        switch (lhs, rhs) {
        case (.operationInProgress, .operationInProgress),
            (.keychainSetupFailed, .keychainSetupFailed),
            (.invalidCredentials, .invalidCredentials):
            return true
        case (.authenticationFailed(let lhsError), .authenticationFailed(let rhsError)),
            (.accountCreationFailed(let lhsError), .accountCreationFailed(let rhsError)),
            (.signOutFailed(let lhsError), .signOutFailed(let rhsError)),
            (.sessionRefreshFailed(let lhsError), .sessionRefreshFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
