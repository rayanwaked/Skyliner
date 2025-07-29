//
//  ClientManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import ATProtoKit
import SwiftUI

@MainActor
@Observable
// MARK: - MANAGER
public final class ClientManager: Sendable {
    // MARK: - PROPERTIES
    /// Holds all necessary connection and authentication settings for the AT Protocol.
    /// Typically, you provide an instance of `ATProtocolConfiguration` with information such as server URL, credentialss, and custom config options.
    ///
    /// Example:
    /// ```swift
    /// let creds = ATProtocolConfiguration(serverURL: "https://bsky.social", credentialss: mycredentialss)
    /// let manager = await ClientManager(credentials: config)
    /// ```
    public let credentials: ATProtocolConfiguration
    /// The main client used for interacting with the AT Protocol APIs, such as authentication, session manager, and general requests.
    ///
    /// Example:
    /// ```swift
    /// let session = await manager.account.authenticate()
    /// ```
    public let account: ATProtoKit
    /// A specialized client for performing Bluesky-specific actions, like timeline manager, posts, or custom Bluesky features.
    ///
    /// Example:
    /// ```swift
    /// let timeline = await manager.bluesky.fetchHomeTimeline()
    /// ```
    public let bluesky: ATProtoBluesky
    
    // MARK: - INITIALIZATION
    public init(credentials: ATProtocolConfiguration) async {
        self.credentials = credentials
        self.account = await ATProtoKit(sessionConfiguration: credentials)
        self.bluesky = ATProtoBluesky(atProtoKitInstance: account)
    }
}

