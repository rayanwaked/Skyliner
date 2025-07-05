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
    
    public private(set) var configuration: ATProtocolConfiguration?
    public private(set) var configurationState: ConfigurationState = .empty
    
    public let configurationContinuation: AsyncStream<ATProtocolConfiguration?>.Continuation
    public let configurationUpdates: AsyncStream<ATProtocolConfiguration?>
    
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
        
        // 2. Setup async stream
        let (stream, continuation) = AsyncStream<ATProtocolConfiguration?>.makeStream(bufferingPolicy: .bufferingNewest(1))
        self.configurationUpdates = stream
        self.configurationContinuation = continuation
        
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
        self.configuration = config
        configurationContinuation.yield(config)
        self.configurationState = .restored
    }
    
    // MARK: - LOG OUT
    public func logout() async throws {
        try await logoutWith(configuration: configuration)
        self.configuration = nil
        configurationContinuation.yield(nil)
        self.configurationState = .empty
        print("🍄✅ Authentication Manager: Log out successful")
    }
    
    // MARK: - REFRESH
    public func refresh() async {
        do {
            let config = try await refreshSession()
            self.configuration = config
            configurationContinuation.yield(config)
            self.configurationState = .restored
        } catch {
            self.configuration = nil
            configurationContinuation.yield(nil)
            self.configurationState = .failed
        }
    }
    
    // MARK: - RESTORE SESSION
    public func restoreSession() async {
        do {
            let config = try await refreshSession()
            await MainActor.run {
                self.configurationState = .restored
                self.configuration = config
                self.configurationContinuation.yield(config)
                print("🍄✅ Authentication Manager: Session restored")
                hapticFeedback(.success)
            }
        } catch {
            print("🍄⛔️ Authentication Manager: Session restoration failed: \(error)")
            await MainActor.run {
                self.configurationState = .failed
                self.configuration = nil
                self.configurationContinuation.yield(nil)
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
