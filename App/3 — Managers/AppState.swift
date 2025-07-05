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
            for await configuration in authenticationManager.configurationUpdates {
                self.configuration = configuration
            }
        }
    }

    // MARK: - SET INSTANCES
    private var _clientManager: ClientManager? = nil
    private let _authenticationManager = AuthenticationManager()
    private let _postManager = PostManager()
    private let _trendManager = TrendManager()
    private let _feedManager = FeedManager()
    private let _profileManager = ProfileManager()
    private var _postModel: [PostModel] = PostModel.placeholders
    private var _trendModel: [TrendModel] = TrendModel.placeholders
    private var _feedModel: [FeedModel] = FeedModel.placeholders
    private var _profileModel: [ProfileModel] = ProfileModel.placeholders

    // MARK: - SET CONFIGURATION
    /// The current ATProtocol configuration.
    /// Updating this ensures all managers stay in sync with the latest configuration.
    var configuration: ATProtocolConfiguration? {
        didSet {
            if let configuration {
                Task { @MainActor in
                    self.clientManager = await ClientManager(configuration: configuration)
                    await updateUserDIDFromConfiguration()
                    postModel = await postManager.getFeed()
                    trendModel = await trendManager.fetchTrends()
                    feedModel = await feedManager.fetchSavedFeeds()
                    profileModel = await profileManager
                        .fetchCurrentUserProfile()
                }
            } else {
                clientManager = nil
            }
            postManager.configuration = configuration
            trendManager.configuration = configuration
            feedManager.configuration = configuration
            profileManager.configuration = configuration
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
}

// MARK: - USER DID STORAGE
extension AppState {
    private var userDIDKey: String { "userDID" }
    var userDID: String? {
        UserDefaults.standard.string(forKey: userDIDKey)
    }
    private func updateUserDIDFromConfiguration() async {
        if let configuration {
            let client = await ATProtoKit(sessionConfiguration: configuration)
            do {
                if let did = try await client.getUserSession()?.sessionDID {
                    UserDefaults.standard.set(did, forKey: userDIDKey)
                }
            } catch {
                print("Error fetching user session: \(error)")
            }
        }
    }
}
