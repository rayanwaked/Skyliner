//
//  AppState.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import ATProtoKit

// MARK: - App State
@Observable
class AppState {
    
    // MARK: - PROPERTIES
    /// Core properties that represent the current state of the app.
    /// Add more properties here as the app's functionality expands.
    
    /// The current ATProtocol configuration.
    /// Updating this ensures all managers stay in sync with the latest configuration.
    var configuration: ATProtocolConfiguration? {
        didSet {
            if let configuration {
                Task { @MainActor in
                    self.clientManager = await ClientManager(configuration: configuration)
                    
                    // MARK: - Set Manager
                    /// Update models with the latest data after configuration changes.
                    /// This keeps the UI and data in sync with the active account.
                    /// Add similar updates here if more models are added in the future.
                    postModel = await postManager.getFeed()
                    trendModel = await trendManager.fetchTrends()
                    feedModel = await feedManager.fetchSavedFeeds()
                }
            } else {
                clientManager = nil
            }
            // MARK: - Set Configuration
            /// Ensure each manager is updated with the new configuration
            /// so they operate with the correct session and data.
            /// Remember to update these assignments if new managers are added in the future.
            postManager.configuration = configuration
            trendManager.configuration = configuration
            feedManager.configuration = configuration
        }
    }
    
    // MARK: - MANAGERS
    /// Manager instances responsible for handling various data operations.
    /// Extend or add new managers as needed for additional features.
    var clientManager: ClientManager? = nil
    var authenticationManager = AuthenticationManager()
    var postManager = PostManager()
    var trendManager = TrendManager()
    var feedManager = FeedManager()
    
    // MARK: - MODELS
    /// Data models representing the current state of posts, trends, and feeds.
    /// Update and expand these models as the app's data requirements grow.
    var postModel: [PostModel] = PostModel.placeholders
    var trendModel: [TrendModel] = TrendModel.placeholders
    var feedModel: [FeedModel] = FeedModel.placeholders
    
    // MARK: - INITIALIZATION
    /// Initializes the AppState and starts listening for configuration updates.
    /// Add any additional startup or initialization tasks here in the future.
    init() {
        Task {
            for await configuration in authenticationManager.configurationUpdates {
                self.configuration = configuration
            }
        }
    }
}

