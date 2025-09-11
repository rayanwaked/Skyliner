//
//  AuthManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
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
    public private(set) var authenticationError: String = ""
    public private(set) var requires2FA: Bool = false
    
    public let clientManagerContinuation: AsyncStream<ClientManager?>.Continuation
    public let clientManagerUpdates: AsyncStream<ClientManager?>
    
    // Keep ONE config alive across the whole 2FA flow
    private var pendingConfig: ATProtocolConfiguration?
    private var signInTask: Task<Void, Never>?
    
    public enum ConfigState {
        case authenticated, unauthenticated, failed, empty, pending2FA
    }
    
    public init() {
        var initConfigState: ConfigState = .empty
        
        if let uuid = keychain.get("session_uuid"), let realUUID = UUID(uuidString: uuid) {
            self.ATProtoKeychain = AppleSecureKeychain(identifier: realUUID)
        } else {
            let newUUID = UUID().uuidString
            guard keychain.set(newUUID, forKey: "session_uuid"),
                  let realUUID = UUID(uuidString: newUUID) else {
                hapticFeedback(.error)
                initConfigState = .empty
                fatalError("Authentication Manager: Failed to create or store session_uuid.")
            }
            self.ATProtoKeychain = AppleSecureKeychain(identifier: realUUID)
        }
        
        let (stream, continuation) = AsyncStream<ClientManager?>.makeStream(bufferingPolicy: .bufferingNewest(1))
        self.clientManagerUpdates = stream
        self.clientManagerContinuation = continuation
        
        self.configState = initConfigState
        
        Task { await restoreSession() }
    }
    
    /// Start sign-in and let ATProtoKit handle 2FA detection
    public func startSignIn(pdsURL: String, handle: String, password: String) async throws {
        // Cancel any existing sign-in attempt
        signInTask?.cancel()
        signInTask = nil
        
        // Clear previous errors
        self.authenticationError = ""
        self.requires2FA = false
        
        let config = ATProtocolConfiguration(pdsURL: pdsURL, keychainProtocol: ATProtoKeychain)
        self.pendingConfig = config
        
        // Set to unauthenticated to show loading state
        if pdsURL == "https://bsky.social" {
            self.configState = .unauthenticated
        }
        
        // Run authenticate in the background
        signInTask = Task { [weak self] in
            do {
                try await config.authenticate(with: handle, password: password)
                await self?.handleSuccessfulAuth(config: config)
            } catch {
                await self?.handleAuthError(error: error)
            }
        }
    }
    
    /// Feed the user's 2FA code into the SAME config that started authenticate()
    public func submitTwoFactorCode(_ code: String) async throws {
        guard let config = pendingConfig else {
            throw AuthError.noPendingConfig
        }
        
        guard !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthError.emptyCode
        }
        
        // Clear any previous errors
        self.authenticationError = ""
        
        // Submit the code
        config.receiveCodeFromUser(code.trimmingCharacters(in: .whitespacesAndNewlines))
        
        // The background task should complete authentication now
        // We don't need to do anything else here - the Task will handle success/failure
    }
    
    /// Allow canceling the in-flight attempt if user backs out
    public func cancelPendingSignIn() {
        signInTask?.cancel()
        signInTask = nil
        pendingConfig = nil
        self.configState = .failed
        self.requires2FA = false
        self.authenticationError = ""
    }
}

// MARK: - METHODS
extension AuthManager {
    // MARK: - AUTH HANDLERS
    private func handleSuccessfulAuth(config: ATProtocolConfiguration) async {
        await setClientManager(with: config)
        await MainActor.run {
            self.configState = .authenticated
            self.pendingConfig = nil
            self.signInTask = nil
            self.requires2FA = false
            self.authenticationError = ""
        }
        print("🍄✅ Authentication Manager: Sign in successful")
    }
    
    private func handleAuthError(error: Error) async {
        await MainActor.run {
            let errorDescription = error.localizedDescription.lowercased()
            
            // Check if this is a 2FA requirement
            if errorDescription.contains("two-factor") ||
                errorDescription.contains("2fa") ||
                errorDescription.contains("authentication code") ||
                errorDescription.contains("verify") {
                self.configState = .pending2FA
                self.requires2FA = true
                self.authenticationError = ""
                print("🍄📱 Authentication Manager: 2FA required")
            } else {
                // This is a real failure
                self.configState = .failed
                self.pendingConfig = nil
                self.signInTask = nil
                self.requires2FA = false
                self.authenticationError = error.localizedDescription
                self.clientManagerContinuation.yield(nil)
                print("🍄❌ Authentication Manager: Sign in failed - \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - LOG OUT
    public func logout() async throws {
        try await logoutWith(config: clientManager?.credentials)
        await MainActor.run {
            self.clientManager = nil
            self.configState = .failed
            self.authenticationError = ""
            self.requires2FA = false
        }
        clientManagerContinuation.yield(nil)
        print("🍄✅ Authentication Manager: Log out successful")
    }
    
    // MARK: - REFRESH
    public func refresh() async {
        do {
            let config = try await refreshSession()
            await setClientManager(with: config)
            await MainActor.run {
                self.configState = .authenticated
                self.authenticationError = ""
            }
        } catch {
            await MainActor.run {
                self.clientManager = nil
                self.configState = .failed
                self.authenticationError = error.localizedDescription
            }
            clientManagerContinuation.yield(nil)
        }
    }
    
    // MARK: - RESTORE SESSION
    public func restoreSession() async {
        do {
            let config = try await refreshSession()
            await setClientManager(with: config)
            self.configState = .authenticated
            self.authenticationError = ""
        } catch {
            // Optionally purge invalid tokens
            try? await clientManager?.credentials.deleteSession()
            self.clientManager = nil
            clientManagerContinuation.yield(nil)
            self.configState = .failed
        }
    }
    
    // MARK: - HELPER METHODS
    private func setClientManager(with config: ATProtocolConfiguration) async {
        let manager = await ClientManager(credentials: config)
        await MainActor.run {
            self.clientManager = manager
        }
        clientManagerContinuation.yield(manager)
    }
    
    private func refreshSession() async throws -> ATProtocolConfiguration {
        let config = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
        try await config.refreshSession()
        return config
    }
    
    private func logoutWith(config: ATProtocolConfiguration?) async throws {
        try await config?.deleteSession()
    }
}

// MARK: - ERRORS
extension AuthManager {
    enum AuthError: LocalizedError {
        case noPendingConfig
        case emptyCode
        
        var errorDescription: String? {
            switch self {
            case .noPendingConfig:
                return "No authentication in progress"
            case .emptyCode:
                return "Please enter a valid authentication code"
            }
        }
    }
}
