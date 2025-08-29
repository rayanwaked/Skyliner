//
//  UserManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit
import NukeUI
import SwiftyBeaver

// MARK: - USER PROFILE DATA
struct UserProfileData {
    var profilePictureURL: URL?
    var bannerURL: URL?
    var follows: Int?
    var followers: Int?
    var posts: Int?
    var description: String?
    var name: String?
    var handle: String?
}

// MARK: - USER STATE
struct UserState {
    var profile = UserProfileData()
    var isLoading = false
    var error: UserError?
}

// MARK: - USER MANAGER
@MainActor
@Observable
public final class UserManager {
    // MARK: - DEPENDENCIES
    @ObservationIgnored
    var appState: AppState?
    internal var clientManager: ClientManager? { appState?.clientManager }
    private var userDID: String? { appState?.userDID }
    
    // MARK: - MODELS
    public let userFeed = PostModel()
    
    // MARK: - STATE
    private(set) var state = UserState()
    private var timelineCursor: String?
    
    // MARK: - COMPUTED PROPERTIES
    var userPosts: [PostItem] { userFeed.posts }
    var isLoading: Bool { state.isLoading }
    var error: UserError? { state.error }
    
    // Profile data accessors
    var profilePictureURL: URL? { state.profile.profilePictureURL }
    var bannerURL: URL? { state.profile.bannerURL }
    var follows: Int? { state.profile.follows }
    var followers: Int? { state.profile.followers }
    var posts: Int? { state.profile.posts }
    var description: String? { state.profile.description }
    var name: String? { state.profile.name }
    var handle: String? { state.profile.handle }
    
    // MARK: - INITALIZATION
    init(appState: AppState? = nil) {
        self.appState = appState
    }
}

// MARK: - PUBLIC INTERFACE
extension UserManager {
    func configure(with appState: AppState) {
        self.appState = appState
    }
    
    func loadProfilePicture() async {
        await withLoadingState {
            try await performLoadProfilePicture()
        }
    }
    
    func loadProfile() async {
        await withLoadingState {
            try await performLoadProfile()
        }
    }
    
    func refreshProfile() async {
        timelineCursor = nil
        userFeed.clear()
        await loadProfile()
    }
    
    func loadMorePosts() async {
        guard !state.isLoading else { return }
        
        await withLoadingState {
            try await performLoadTimeline()
        }
    }
}

// MARK: - PRIVATE OPERATIONS
private extension UserManager {
    func performLoadProfilePicture() async throws {
        guard let clientManager = clientManager,
              let userDID = userDID,
              !userDID.isEmpty else {
            throw UserError.invalidConfiguration
        }
        
        let profile = try await clientManager.account.getProfile(for: userDID)
        state.profile.profilePictureURL = profile.avatarImageURL
    }
    
    func performLoadProfile() async throws {
        guard let clientManager = clientManager,
              let userDID = userDID,
              !userDID.isEmpty else {
            throw UserError.invalidConfiguration
        }
        
        let profile = try await clientManager.account.getProfile(for: userDID)
        let authorFeed = try await clientManager.account.getAuthorFeed(by: userDID)
        
        updateProfileData(from: profile)
        userFeed.updatePosts(authorFeed.feed)
        timelineCursor = authorFeed.cursor
    }
    
    func performLoadTimeline() async throws {
        guard let clientManager = clientManager,
              let userDID = userDID,
              !userDID.isEmpty else {
            throw UserError.invalidConfiguration
        }
        
        let authorFeed = try await clientManager.account.getAuthorFeed(
            by: userDID,
            cursor: timelineCursor
        )
        
        timelineCursor = authorFeed.cursor
        
        if userFeed.posts.isEmpty {
            userFeed.updatePosts(authorFeed.feed)
        } else {
            userFeed.appendPosts(authorFeed.feed)
        }
    }
    
    func updateProfileData(from profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition) {
        state.profile = UserProfileData(
            profilePictureURL: profile.avatarImageURL,
            bannerURL: profile.bannerImageURL,
            follows: profile.followCount,
            followers: profile.followerCount,
            posts: profile.postCount,
            description: profile.description,
            name: profile.displayName,
            handle: profile.actorHandle
        )
    }
    
    func withLoadingState<T>(_ operation: () async throws -> T) async -> T? {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }
        
        do {
            return try await operation()
        } catch let error as UserError {
            state.error = error
            log.error("Operation failed: \(error)")
            return nil
        } catch {
            let userError = UserError.operationFailed(error)
            state.error = userError
            log.error("Operation failed: \(userError)")
            return nil
        }
    }
}

// MARK: - POST INTERACTION CONFORMANCE
extension UserManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        userFeed.findPost(by: postID)
    }
}

// MARK: - ERRORS
enum UserError: LocalizedError {
    case invalidConfiguration
    case clientUnavailable
    case userDIDMissing
    case operationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Client manager or user DID is not available"
        case .clientUnavailable:
            return "Client manager is not available"
        case .userDIDMissing:
            return "User DID is missing or invalid"
        case .operationFailed(let error):
            return "User operation failed: \(error.localizedDescription)"
        }
    }
}

