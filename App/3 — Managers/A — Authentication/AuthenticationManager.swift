//
//  AuthenticationManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - Imports
import SwiftUI
import ATProtoKit
@preconcurrency import KeychainSwift

// MARK: - Authentication Manager
@Observable
public final class AuthenticationManager: @unchecked Sendable {
    private let keychain = KeychainSwift()
    private let ATProtoKeychain: AppleSecureKeychain
    private let functions: AuthenticationFunctions

    public private(set) var configuration: ATProtocolConfiguration?
    public private(set) var configurationState: configurationState = .empty

    private let configurationContinuation: AsyncStream<ATProtocolConfiguration?>.Continuation
    public let configurationUpdates: AsyncStream<ATProtocolConfiguration?>

    public enum configurationState {
        case restored
        case failed
        case empty
    }
    
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

        self.functions = AuthenticationFunctions(secureKeychain: ATProtoKeychain)

        // 2. Setup async stream
        let (stream, continuation) = AsyncStream<ATProtocolConfiguration?>.makeStream(bufferingPolicy: .bufferingNewest(1))
        self.configurationUpdates = stream
        self.configurationContinuation = continuation

        // 3. Try session restore
        Task {
            await restoreSession()
        }
    }

    // MARK: - Authenticate
    func authenticate(handle: String, password: String) async throws {
        let config = try await functions.authenticate(handle: handle, password: password)
        self.configuration = config
        configurationContinuation.yield(config)
        self.configurationState = .restored
    }

    // MARK: - Log Out
    func logout() async throws {
        try await functions.logout(configuration: configuration)
        self.configuration = nil
        configurationContinuation.yield(nil)
        self.configurationState = .empty
        print("🍄✅ Authentication Manager: Log out successful")
    }

    // MARK: - Refresh
    func refresh() async {
        do {
            let config = try await functions.refresh()
            self.configuration = config
            configurationContinuation.yield(config)
            self.configurationState = .restored
        } catch {
            self.configuration = nil
            configurationContinuation.yield(nil)
            self.configurationState = .failed
        }
    }

    // MARK: - Restore Session
    func restoreSession() async {
        do {
            let config = try await functions.refresh()
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
}

