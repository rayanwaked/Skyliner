//
//  AppState.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import ATProtoKit

// MARK: - APP STATE
@Observable
class AppState {
    // MARK: - PRIVATE KEYS
    /// Key used for storing the user's DID in UserDefaults.
    private let userDIDKey = "userDID"
    
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
                    
                    // Update the stored user DID from the current configuration.
                    await updateUserDIDFromConfiguration()
                    
                    // MARK: - SET MANAGER
                    /// Update models with the latest data after configuration changes.
                    /// This keeps the UI and data in sync with the active account.
                    /// Add similar updates here if more models are added in the future.
                    postModel = await postManager.getFeed()
                    trendModel = await trendManager.fetchTrends()
                    feedModel = await feedManager.fetchSavedFeeds()
                    profileModel = await profileManager
                        .fetchCurrentUserProfile()
                }
            } else {
                clientManager = nil
            }
            // MARK: - SET CONFIGURATION
            /// Ensure each manager is updated with the new configuration
            /// so they operate with the correct session and data.
            /// Remember to update these assignments if new managers are added in the future.
            postManager.configuration = configuration
            trendManager.configuration = configuration
            feedManager.configuration = configuration
            profileManager.configuration = configuration
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
    var profileManager = ProfileManager()
    
    // MARK: - MODELS
    /// Data models representing the current state of posts, trends, and feeds.
    /// Update and expand these models as the app's data requirements grow.
    var postModel: [PostModel] = PostModel.placeholders
    var trendModel: [TrendModel] = TrendModel.placeholders
    var feedModel: [FeedModel] = FeedModel.placeholders
    var profileModel: [ProfileModel] = ProfileModel.placeholders
    
    // MARK: - USER DID STORAGE
    /// Retrieves the stored user DID from UserDefaults.
    /// This allows other parts of the app to access the user's DID persistent storage.
    var userDID: String? {
        UserDefaults.standard.string(forKey: userDIDKey)
    }
    
    /// Fetches the user DID from the current client session and stores it in UserDefaults.
    private func updateUserDIDFromConfiguration() async {
        // Attempt to retrieve the client instance from the current configuration.
        if let configuration {
            let client = await ATProtoKit(sessionConfiguration: configuration)
            do {
                if let did = try await client.getUserSession()?.sessionDID {
                    UserDefaults.standard.set(did, forKey: userDIDKey)
                }
            } catch {
                // Handle or log the error as needed. For now, just print it.
                print("Error fetching user session: \(error)")
            }
        }
    }
    
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
