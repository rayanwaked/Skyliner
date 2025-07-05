//
//  ClientManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - IMPORTS
@preconcurrency import ATProtoKit
import SwiftUI

// MARK: - CLIENT MANAGER
@Observable
public final class ClientManager: Sendable {
    /// Holds all necessary connection and authentication settings for the AT Protocol.
    /// Typically, you provide an instance of `ATProtocolConfiguration` with information such as server URL, credentials, and custom configuration options.
    ///
    /// Example:
    /// ```swift
    /// let config = ATProtocolConfiguration(serverURL: "https://bsky.social", credentials: myCredentials)
    /// let manager = await ClientManager(configuration: config)
    /// ```
    public let configuration: ATProtocolConfiguration
    /// The main client used for interacting with the AT Protocol APIs, such as authentication, session management, and general requests.
    ///
    /// Example:
    /// ```swift
    /// let session = await manager.protoClient.authenticate()
    /// ```
    public let protoClient: ATProtoKit
    /// A specialized client for performing Bluesky-specific actions, like timeline management, posts, or custom Bluesky features.
    ///
    /// Example:
    /// ```swift
    /// let timeline = await manager.blueskyClient.fetchHomeTimeline()
    /// ```
    public let blueskyClient: ATProtoBluesky
    
    /// Creates a new `ClientManager` configured with your protocol settings.
    ///
    /// This sets up the main protocol client and Bluesky client for app-wide use.
    ///
    /// Example:
    /// ```swift
    /// let config = ATProtocolConfiguration(serverURL: "https://bsky.social", credentials: myCredentials)
    /// let manager = await ClientManager(configuration: config)
    /// ```
    /// - Parameter configuration: The protocol configuration containing server details and authentication info.
    public init(configuration: ATProtocolConfiguration) async {
        self.configuration = configuration
        self.protoClient = await ATProtoKit(sessionConfiguration: configuration)
        self.blueskyClient = ATProtoBluesky(atProtoKitInstance: protoClient)
    }
}

