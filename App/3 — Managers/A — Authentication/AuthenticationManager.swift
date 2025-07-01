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

    private let configurationContinuation: AsyncStream<ATProtocolConfiguration?>.Continuation
    public let configurationUpdates: AsyncStream<ATProtocolConfiguration?>

    public init() {
        // 1. Set up secure keychain
        if let uuid = keychain.get("session_uuid"), let realUUID = UUID(uuidString: uuid) {
            self.ATProtoKeychain = AppleSecureKeychain(identifier: realUUID)
        } else {
            let newUUID = UUID().uuidString
            guard keychain.set(newUUID, forKey: "session_uuid"),
                  let realUUID = UUID(uuidString: newUUID) else {
                hapticFeedback(.error)
                fatalError("🍄⛔️ AuthenticationManager: Failed to create or store session_uuid.")
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
    }

    // MARK: - Log Out
    func logout() async throws {
        try await functions.logout(configuration: configuration)
        self.configuration = nil
        configurationContinuation.yield(nil)
    }

    // MARK: - Refresh
    func refresh() async {
        do {
            let config = try await functions.refresh()
            self.configuration = config
            configurationContinuation.yield(config)
        } catch {
            self.configuration = nil
            configurationContinuation.yield(nil)
        }
    }

    // MARK: - Restore Session
    func restoreSession() async {
        do {
            let config = try await functions.refresh()
            await MainActor.run {
                self.configuration = config
                self.configurationContinuation.yield(config)
                print("🍄✅ AuthenticationManager: Session restored")
                hapticFeedback(.success)
            }
        } catch {
            print("🍄⛔️ AuthenticationManager: Session restoration failed: \(error)")
            await MainActor.run {
                self.configuration = nil
                self.configurationContinuation.yield(nil)
                hapticFeedback(.error)
            }
        }
    }
}

