//
//  AuthenticationManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - IMPORTS
import SwiftUI
import ATProtoKit
@preconcurrency import KeychainSwift

// MARK: - AUTHENTICATION MANAGER
@Observable
public final class AuthenticationManager: @unchecked Sendable {
    //MARK: - VARIABLES
    let keychain = KeychainSwift()
    let ATProtoKeychain: AppleSecureKeychain
    
    public private(set) var clientManager: ClientManager?
    public private(set) var configurationState: ConfigurationState = .empty
    
    public let clientManagerContinuation: AsyncStream<ClientManager?>.Continuation
    public let clientManagerUpdates: AsyncStream<ClientManager?>
    
    public enum ConfigurationState {
        case restored
        case failed
        case empty
    }
    
    // MARK: - INITIALIZER
    public init() {
        // 1. Set up secure keychain
        if let uuid = keychain.get("session_uuid"), let realUUID = UUID(uuidString: uuid) {
            self.ATProtoKeychain = AppleSecureKeychain(identifier: realUUID)
            self.configurationState = .restored
        } else {
            let newUUID = UUID().uuidString
            guard keychain.set(newUUID, forKey: "session_uuid"),
                  let realUUID = UUID(uuidString: newUUID) else {
                hapticFeedback(.error)
                self.configurationState = .failed
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

// MARK: - AUTHENTICATION MANAGER FUNCTIONS
extension AuthenticationManager {
    // MARK: - AUTHENTICATE
    public func authenticate(handle: String, password: String) async throws {
        let config = try await authenticateWith(handle: handle, password: password)
        let manager = await ClientManager(configuration: config)
        self.clientManager = manager
        clientManagerContinuation.yield(manager)
        self.configurationState = .restored
    }
    
    // MARK: - LOG OUT
    public func logout() async throws {
        try await logoutWith(configuration: clientManager?.configuration)
        self.clientManager = nil
        clientManagerContinuation.yield(nil)
        self.configurationState = .empty
        print("🍄✅ Authentication Manager: Log out successful")
    }
    
    // MARK: - REFRESH
    public func refresh() async {
        do {
            let config = try await refreshSession()
            let manager = await ClientManager(configuration: config)
            self.clientManager = manager
            clientManagerContinuation.yield(manager)
            self.configurationState = .restored
        } catch {
            self.clientManager = nil
            clientManagerContinuation.yield(nil)
            self.configurationState = .failed
        }
    }
    
    // MARK: - RESTORE SESSION
    public func restoreSession() async {
        do {
            let config = try await refreshSession()
            let manager = await ClientManager(configuration: config)
            await MainActor.run {
                self.configurationState = .restored
                self.clientManager = manager
                self.clientManagerContinuation.yield(manager)
                print("🍄✅ Authentication Manager: Session restored")
                hapticFeedback(.success)
            }
        } catch {
            print("🍄⛔️ Authentication Manager: Session restoration failed: \(error)")
            await MainActor.run {
                self.configurationState = .failed
                self.clientManager = nil
                self.clientManagerContinuation.yield(nil)
                hapticFeedback(.error)
            }
        }
    }
    
    // MARK: - AUTH METHODS (inlined from AuthenticationFunctions)
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
    
    private func logoutWith(configuration: ATProtocolConfiguration?) async throws {
        try await configuration?.deleteSession()
    }
}
