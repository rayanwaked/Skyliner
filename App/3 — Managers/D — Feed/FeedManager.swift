//
//  FeedManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/1/25.
//

// MARK: - IMPORTS
import Foundation
import ATProtoKit

// MARK: - FEED MANAGER
@MainActor
@Observable
public class FeedManager {
    @ObservationIgnored
    public private(set) var savedFeeds: [FeedModel] = []
    @ObservationIgnored
    public private(set) var clientManager: ClientManager? = nil
    @ObservationIgnored
    public var configuration: ATProtocolConfiguration?
    
    public init() {}
    public init(configuration: ATProtocolConfiguration? = nil) {
        self.configuration = configuration
    }
}

// MARK: - FEED MANAGER FUNCTIONS
extension FeedManager {
    // MARK: - FETCH SAVED FEEDS
    public func fetchSavedFeeds() async -> [FeedModel] {
        guard let configuration = configuration else {
            print("🍄⛔️ FeedManager: Configuration is nil")
            return []
        }
        
        let client = await ATProtoKit(sessionConfiguration: configuration)
        let manager = await ClientManager(configuration: configuration)
        
        // MARK: - IMPLEMENT SAVED FEEDS
        do {
            let output = try await client.getPopularFeedGenerators(matching: nil, limit: 15)
            await print("🍄✅ FeedManager: \(try client.getUserSession()?.sessionDID ?? "No Session DID")"
            )
            
            savedFeeds = output.feeds.compactMap {
                FeedModel(
                    uri: $0.feedURI,
                    displayName: $0.displayName,
                    description: $0.description,
                    avatarImageURL: $0.avatarImageURL,
                    creatorHandle: $0.creator.actorHandle
                )
            }
            
            print("🍄✅ FeedManager: Loaded saved feeds")
            clientManager = manager
            return savedFeeds
        } catch {
            print("🍄⛔️ FeedManager: Failed to load saved feeds: \(error)")
            return []
        }
    }
}

