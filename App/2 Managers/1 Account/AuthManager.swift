//
//  AuthManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import ATProtoKit
import KeychainSwift

@Observable
public final class AuthManager: @unchecked Sendable {
    //MARK: - PROPERTIES
    let keychain = KeychainSwift()
    let ATProtoKeychain: AppleSecureKeychain
    
    public private(set) var clientManager: ClientManager?
    public private(set) var configState: ConfigState = .empty
    
    public let clientManagerContinuation: AsyncStream<ClientManager?>.Continuation
    public let clientManagerUpdates: AsyncStream<ClientManager?>
    
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
}

// MARK: - METHODS
extension AuthManager {
    // MARK: - AUTHENTICATE
    public func authenticate(handle: String, password: String) async throws {
        let config = try await authenticateWith(handle: handle, password: password)
        await setClientManager(with: config)
        self.configState = .restored
    }
    
    // MARK: - LOG OUT
    public func logout() async throws {
        try await logoutWith(config: clientManager?.credentials)
        self.clientManager = nil
        clientManagerContinuation.yield(nil)
        self.configState = .empty
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
    
    private func authenticateWith(handle: String, password: String) async throws -> ATProtocolConfiguration {
        let config = ATProtocolConfiguration(keychainProtocol: ATProtoKeychain)
        try await config.authenticate(with: handle, password: password)
        return config
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
