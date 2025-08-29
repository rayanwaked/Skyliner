//
//  ProfileManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/24/25.
//

import SwiftUI
import SwiftyBeaver
import NukeUI
import ATProtoKit

// MARK: - PROFILE STATE
public struct ProfileState {
    var profilePictureURL: URL? = URL(string: "")
    var bannerURL: URL? = URL(string: "")
    var follows: Int? = 0
    var followers: Int? = 0
    var posts: Int? = 0
    var description: String? = ""
    var name: String? = ""
    var handle: String? = ""
    var isLoading = false
}

// MARK: - PROFILE MANAGER
@MainActor
@Observable
public final class ProfileManager {
    // MARK: - DEPENDENCIES
    @ObservationIgnored
    var appState: AppState?
    internal var clientManager: ClientManager? { appState?.clientManager }
    
    // MARK: - STATE
    private(set) var state = ProfileState()
    private(set) var profileFeed = PostModel()
    private var timelineCursor: String?
    
    // MARK: - IDENTIFIER
    private let userDID: String
    
    // MARK: - COMPUTED PROPERTIES
    var profilePosts: [PostItem] { profileFeed.posts }
    var isLoading: Bool { state.isLoading }
    
    // MARK: - INITALIZATION
    init(userDID: String, appState: AppState? = nil) {
        self.userDID = userDID
        self.appState = appState
    }
}

// MARK: - PUBLIC INTERFACE
extension ProfileManager {
    func configure(with appState: AppState) {
        self.appState = appState
    }
    
    func loadProfile() async {
        await withLoadingState {
            try await performLoadProfile()
        }
    }
    
    func refreshProfile() async {
        timelineCursor = nil
        profileFeed.clear()
        await loadProfile()
    }
    
    func loadMorePosts() async {
        guard !state.isLoading else { return }
        
        await withLoadingState {
            try await performLoadMorePosts()
        }
    }
}

// MARK: - PRIVATE OPERATIONS
private extension ProfileManager {
    func performLoadProfile() async throws {
        guard let clientManager = clientManager else {
            throw ProfileError.clientUnavailable
        }
        
        let profile = try await clientManager.account.getProfile(for: userDID)
        let authorFeed = try await clientManager.account.getAuthorFeed(by: userDID)
        
        updateState(from: profile)
        profileFeed.updatePosts(authorFeed.feed)
        timelineCursor = authorFeed.cursor
    }
    
    func performLoadMorePosts() async throws {
        guard let clientManager = clientManager else {
            throw ProfileError.clientUnavailable
        }
        
        let authorFeed = try await clientManager.account.getAuthorFeed(
            by: userDID,
            cursor: timelineCursor
        )
        
        timelineCursor = authorFeed.cursor
        profileFeed.appendPosts(authorFeed.feed)
    }
    
    func updateState(from profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition) {
        state.profilePictureURL = profile.avatarImageURL
        state.bannerURL = profile.bannerImageURL
        state.follows = profile.followCount
        state.followers = profile.followerCount
        state.posts = profile.postCount
        state.name = profile.displayName
        state.handle = profile.actorHandle
        state.description = profile.description
    }
    
    func withLoadingState<T>(_ operation: () async throws -> T) async -> T? {
        state.isLoading = true
        defer { state.isLoading = false }
        
        do {
            return try await operation()
        } catch {
            log.error("Operation failed: \(error)")
            return nil
        }
    }
}

// MARK: - POST INTERACTION CONFORMANCE
extension ProfileManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        profileFeed.findPost(by: postID)
    }
}

// MARK: - ERRORS
enum ProfileError: LocalizedError {
    case clientUnavailable
    case invalidUserDID
    
    var errorDescription: String? {
        switch self {
        case .clientUnavailable:
            return "Client manager is not available"
        case .invalidUserDID:
            return "Invalid user DID provided"
        }
    }
}

