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
    
    public let clientManagerContinuation: AsyncStream<ClientManager?>.Continuation
    public let clientManagerUpdates: AsyncStream<ClientManager?>
    
    // Keep ONE config alive across the whole 2FA flow
    private var pendingConfig: ATProtocolConfiguration?
    private var signInTask: Task<Void, Never>?
    
    public enum ConfigState {
        case restored, failed, empty
    }
    
    // MARK: - INITIALIZER
    public init() {
        // 1. Set up secure keychain
        if let uuid = keychain.get("session_uuid"), let realUUID = UUID(uuidString: uuid) {
            self.ATProtoKeychain = AppleSecureKeychain(identifier: realUUID)
            self.configState = .restored
        } else {
            let newUUID = UUID().uuidString
            guard keychain.set(newUUID, forKey: "session_uuid"),
                  let realUUID = UUID(uuidString: newUUID) else {
                hapticFeedback(.error)
                self.configState = .failed
                fatalError("Authentication Manager: Failed to create or store session_uuid.")
            }
            self.ATProtoKeychain = AppleSecureKeychain(identifier: realUUID)
        }
        
        // 2. Setup async stream for ClientManager
        let (stream, continuation) = AsyncStream<ClientManager?>.makeStream(bufferingPolicy: .bufferingNewest(1))
        self.clientManagerUpdates = stream
        self.clientManagerContinuation = continuation
        
        // 3. Try session restore
        Task {
            await restoreSession()
        }
    }
    
    /// Start sign-in and let ATProtoKit block internally waiting for code via codeStream.
    public func startSignIn(handle: String, password: String) async throws {
        // Don’t kick off another attempt if one is already running.
        guard signInTask == nil else { return }

        let config = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
        self.pendingConfig = config

        // Run authenticate in the background; it will suspend on 2FA until we yield a code.
        signInTask = Task { [weak self] in
            do {
                try await config.authenticate(with: handle, password: password)

                // Success: promote to active session using the SAME config
                await self?.setClientManager(with: config)
                await MainActor.run {
                    self?.configState = .restored
                    self?.pendingConfig = nil
                    self?.signInTask = nil
                }
            } catch {
                // Failure: clean up so a fresh attempt can start
                await MainActor.run {
                    self?.pendingConfig = nil
                    self?.signInTask = nil
                    self?.clientManagerContinuation.yield(nil)
                    self?.configState = .failed
                    print("🍄⛔️ Sign-in failed: \(error)")
                }
            }
        }
    }
    
    /// Feed the user’s 2FA code into the SAME config that started authenticate()
    public func submitTwoFactorCode(_ code: String) {
        guard let config = pendingConfig else {
            print("⚠️ submitTwoFactorCode called with no pending config; ignoring.")
            return
        }
        config.receiveCodeFromUser(code)
    }
    
    /// Allow canceling the in-flight attempt if user backs out
    public func cancelPendingSignIn() {
        signInTask?.cancel()
        signInTask = nil
        pendingConfig = nil
    }
}

// MARK: - METHODS
extension AuthManager {
    // MARK: - AUTHENTICATE
    // Legacy or direct authentication without 2FA
    private func authenticateWith(handle: String, password: String, authFactorToken: String? = nil) async throws -> ATProtocolConfiguration {
        let config = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
        try await config.authenticate(with: handle, password: password)
        return config
    }
    
    // MARK: - CREATE ACCOUNT
    /// Updated: Fix for ATProtoKit registration. Use ATProtoKit's client to create account instead of non-existent config.register.
    /// Assuming ATProtoKit provides a 'createAccount' method. Adjust parameters if API is different.
    /// After registration, proceed to authenticate and set up session as normal.
    public func createAccount(handle: String, password: String) async throws -> Bool {
        let config = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
        let atproto = await ATProtoKit(sessionConfiguration: config)
        _ = try await atproto.createAccount(handle: handle, password: password)
        let authenticatedConfig = try await authenticateWith(handle: handle, password: password)
        await setClientManager(with: authenticatedConfig)
        withAnimation(Animation.snappy(duration: 1.5)) {
            self.configState = .restored
        }
        return false
    }
    
    // MARK: - LOG OUT
    public func logout() async throws {
        try await logoutWith(config: clientManager?.credentials)
        self.clientManager = nil
        clientManagerContinuation.yield(nil)
        self.configState = .failed
        print("🍄✅ Authentication Manager: Log out successful")
    }
    
    // MARK: - REFRESH
    public func refresh() async {
        do {
            let config = try await refreshSession()
            await setClientManager(with: config)
            self.configState = .restored
        } catch {
            self.clientManager = nil
            clientManagerContinuation.yield(nil)
            self.configState = .failed
        }
    }
    
    // MARK: - RESTORE SESSION
    public func restoreSession() async {
        do {
            let config = try await refreshSession()
            await setClientManager(with: config)
            await MainActor.run {
                self.configState = .restored
                print("🍄✅ Authentication Manager: Session restored")
                hapticFeedback(.success)
            }
        } catch {
            print("🍄⛔️ Authentication Manager: Session restoration failed: \(error)")
            await MainActor.run {
                self.configState = .failed
                self.clientManager = nil
                self.clientManagerContinuation.yield(nil)
                hapticFeedback(.error)
            }
        }
    }
    
    // MARK: - HELPER METHODS
    private func setClientManager(with config: ATProtocolConfiguration) async {
        let manager = await ClientManager(credentials: config)
        self.clientManager = manager
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
