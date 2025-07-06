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
    // MARK: - INITIALIZATION
    /// Initializes the AppState and starts listening for configuration updates.
    /// Add any additional startup or initialization tasks here in the future.
    init() {
        Task {
            for await clientManager in authenticationManager.clientManagerUpdates {
                await MainActor.run {
                    self.clientManager = clientManager
                    self.configuration = clientManager?.configuration
                    
                    // Update all managers with the new clientManager
                    self.updateManagers(with: clientManager)
                }
            }
        }
    }
    
    // MARK: - SET INSTANCES
    // Managers
    private var _clientManager: ClientManager? = nil
    private let _authenticationManager = AuthenticationManager()
    private let _postManager = PostManager()
    private let _trendManager = TrendManager()
    private let _feedManager = FeedManager()
    private let _profileManager = ProfileManager()
    private let _notificationManager = NotificationManager()
    // Models
    private var _postModel: [PostModel] = PostModel.placeholders
    private var _trendModel: [TrendModel] = TrendModel.placeholders
    private var _feedModel: [FeedModel] = FeedModel.placeholders
    private var _profileModel: [ProfileModel] = ProfileModel.placeholders
    private var _notificationModel: [NotificationModel] = NotificationModel.placeholders
    
    // MARK: - UPDATE MANAGERS
    /// Updates all managers with the current ClientManager instance
    private func updateManagers(with clientManager: ClientManager?) {
        _postManager.clientManager = clientManager
        _trendManager.clientManager = clientManager
        _feedManager.clientManager = clientManager
        _profileManager.clientManager = clientManager
        _notificationManager.clientManager = clientManager
    }
    
    // MARK: - SET CONFIGURATION
    /// The current ATProtocol configuration.
    /// Updating this ensures all managers stay in sync with the latest configuration.
    var configuration: ATProtocolConfiguration? {
        didSet {
            if configuration != nil {
                Task { @MainActor in
                    await updateUserDIDFromConfiguration()
                    postModel = await postManager.getFeed()
                    trendModel = await trendManager.fetchTrends()
                    feedModel = await feedManager.fetchSavedFeeds()
                    profileModel = await profileManager.fetchCurrentUserProfile()
                    notificationModel = await notificationManager.fetchNotifications()
                }
            }
        }
    }
}

// MARK: - MANAGERS
extension AppState {
    var clientManager: ClientManager? {
        get { _clientManager }
        set { _clientManager = newValue }
    }
    var authenticationManager: AuthenticationManager { _authenticationManager }
    var postManager: PostManager { _postManager }
    var trendManager: TrendManager { _trendManager }
    var feedManager: FeedManager { _feedManager }
    var profileManager: ProfileManager { _profileManager }
    var notificationManager: NotificationManager { _notificationManager }
}

// MARK: - MODELS
extension AppState {
    var postModel: [PostModel] {
        get { _postModel }
        set { _postModel = newValue }
    }
    var trendModel: [TrendModel] {
        get { _trendModel }
        set { _trendModel = newValue }
    }
    var feedModel: [FeedModel] {
        get { _feedModel }
        set { _feedModel = newValue }
    }
    var profileModel: [ProfileModel] {
        get { _profileModel }
        set { _profileModel = newValue }
    }
    var notificationModel: [NotificationModel] {
        get { _notificationModel }
        set { _notificationModel = newValue }
    }
}

// MARK: - USER DID STORAGE
extension AppState {
    private var userDIDKey: String { "userDID" }
    var userDID: String? {
        UserDefaults.standard.string(forKey: userDIDKey)
    }
    private func updateUserDIDFromConfiguration() async {
        if let clientManager = clientManager {
            // Use the already initialized client from ClientManager
            do {
                if let did = try await clientManager.protoClient.getUserSession()?.sessionDID {
                    UserDefaults.standard.set(did, forKey: userDIDKey)
                }
            } catch {
                print("Error fetching user session: \(error)")
            }
        }
    }
}
