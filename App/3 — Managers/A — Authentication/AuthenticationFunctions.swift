//
//  AuthenticationFunctions.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - Imports
import ATProtoKit

// MARK: - Authentication Functions
public final class AuthenticationFunctions {
    private let secureKeychain: AppleSecureKeychain

    public init(secureKeychain: AppleSecureKeychain) {
        self.secureKeychain = secureKeychain
    }

    // MARK: - Authenticate
    public func authenticate(handle: String, password: String) async throws -> ATProtocolConfiguration {
        let config = ATProtocolConfiguration(keychainProtocol: secureKeychain)
        try await config.authenticate(with: handle, password: password)
        return config
    }

    // MARK: - Refresh
    public func refresh() async throws -> ATProtocolConfiguration {
        let config = ATProtocolConfiguration(keychainProtocol: secureKeychain)
        try await config.refreshSession()
        return config
    }

    // MARK: - Log Out
    public func logout(configuration: ATProtocolConfiguration?) async throws {
        try await configuration?.deleteSession()
    }
}
