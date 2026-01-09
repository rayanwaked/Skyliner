//
//  UserManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit
import NukeUI

@MainActor
@Observable
// MARK: - MANAGER
public final class UserManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    var userDID: String? { appState?.userDID }
    var profilePictureURL: URL?
    var bannerURL: URL?
    var follows: Int?
    var followers: Int?
    var posts: Int?
    var description: String?
    var name: String?
    var handle: String?
    var isLoadingProfile = false
    
    public let userFeed = PostModel()
    private var timelineCursor: String?
    
    // MARK: - COMPUTED PROPERTIES
    var userPosts: [PostItem] { userFeed.posts }
}

// MARK: - CORE FUNCTIONS
extension UserManager {
    // MARK: - LOAD PROFILE PICTURE
    public func loadProfilePicture() async {
        guard let clientManager, let userDID, !userDID.isEmpty else {
            logError("No clientManager or userDID available")
            return
        }
        
        await execute("Loading profile picture") {
            isLoadingProfile = true
            let profile = try await clientManager.account.getProfile(for: userDID)
            profilePictureURL = profile.avatarImageURL
            isLoadingProfile = false
        }
    }
    
    // MARK: - LOAD TIMELINE
    public func loadTimeline() async {
        guard let clientManager, let userDID, !userDID.isEmpty else {
            logError("No clientManager or userDID available")
            return
        }
        
        await execute("Loading user timeline") {
            isLoadingProfile = true
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
            isLoadingProfile = false
        }
    }
    
    // MARK: - LOAD PROFILE
    public func loadProfile() async {
        guard let clientManager, let userDID, !userDID.isEmpty else {
            logError("No clientManager or userDID available")
            return
        }
        
        await execute("Loading user profile") {
            isLoadingProfile = true
            let profile = try await clientManager.account.getProfile(for: userDID)
            let authorFeed = try await clientManager.account.getAuthorFeed(by: userDID)
            
            updateProfile(from: profile)
            userFeed.updatePosts(authorFeed.feed)
            timelineCursor = authorFeed.cursor
            isLoadingProfile = false
        }
    }
    
    // MARK: - REFRESH PROFILE
    public func refreshProfile() async {
        timelineCursor = nil
        userFeed.clear()
        await loadProfile()
    }
    
    // MARK: - LOAD MORE POSTS
    public func loadMorePosts() async {
        await loadTimeline()
    }
    
    // MARK: - PRIVATE HELPERS
    private func updateProfile(from profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition) {
        profilePictureURL = profile.avatarImageURL
        bannerURL = profile.bannerImageURL
        follows = profile.followCount
        followers = profile.followerCount
        posts = profile.postCount
        name = profile.displayName
        handle = profile.actorHandle
        description = profile.description
    }
    
    private func execute(_ operationName: String, operation: () async throws -> Void) async {
        do {
            try await operation()
            logSuccess("\(operationName) completed successfully")
        } catch {
            logError("Failed to \(operationName.lowercased()): \(error.localizedDescription)")
        }
    }
    
    private func logSuccess(_ message: String) {
        print("\(message)")
    }
    
    private func logError(_ message: String) {
        print("\(message)")
    }
}

// MARK: - POST INTERACTION CONFORMANCE
extension UserManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        userFeed.findPost(by: postID)
    }
}
