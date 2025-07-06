//
//  TrendManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/1/25.
//

// MARK: - Imports
import SwiftUI
import ATProtoKit

// MARK: - TREND MANAGER
@MainActor
@Observable
public class TrendManager {
    public private(set) var trends: [TrendModel] = []
    @ObservationIgnored
    public var clientManager: ClientManager? = nil
}

// MARK: - TREND MANAGER FUNCTIONS
extension TrendManager {
    // MARK: - FETCH TRENDS
    /// Fetches trending topics from the network (stub implementation).
    public func fetchTrends() async -> [TrendModel] {
        guard let configuration = clientManager?.configuration else {
            print("🍄⛔️ ProfileManager: No configuration available")
            return []
        }
        let client = await ATProtoKit(sessionConfiguration: configuration)
        let manager = await Skyliner.ClientManager(configuration: configuration)
        
        do {
            let trendingTopics = try await client.getTrendingTopics()
            //            print("Fetched trending topics: \(trendingTopics)")
            trends = trendingTopics.topics.map {
                TrendModel(
                    topic: $0.topic,
                    displayName: $0.topic,
                    description: $0.description,
                    link: $0.link
                )
            }
            
        } catch {
            print("Error fetching trending topics: \(error)")
            trends = []
        }
        clientManager = manager
        return trends
    }
}
