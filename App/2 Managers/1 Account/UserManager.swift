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
public final class UserManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState? = nil
    var clientManager: ClientManager? { appState?.clientManager }
    var userDID: String? { appState?.userDID }
    var profilePictureURL: URL? = nil
    var bannerURL: URL? = nil
    var follows: Int? = nil
    var followers: Int? = nil
    var posts: Int? = nil
    var description: String? = nil
    var name: String? = nil
    var handle: String? = nil
    var isLoadingProfile = false
    
    // Integrated PostModel for timeline
    public let userFeed = PostModel()
    private var timelineCursor: String?
    
    // MARK: - COMPUTED PROPERTIES
    var postData: [(authorDID: String, postID: String, imageURL: URL?, name: String, handle: String, time: String, message: String, embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?)] {
        userFeed.postData
    }
    
    // Legacy timeline property for backward compatibility
    var timeline: [AppBskyLexicon.Feed.FeedViewPostDefinition]? {
        userFeed.posts.compactMap { $0.rawPost as? AppBskyLexicon.Feed.FeedViewPostDefinition }
    }
    
    // MARK: - METHODS
    public func loadProfilePicture() async {
        guard let clientManager = self.clientManager else {
            print("❌ No clientManager available")
            return
        }
        
        guard let userDID, !userDID.isEmpty else {
            print("❌ No valid userDID available")
            return
        }
        
        isLoadingProfile = true
        
        do {
            let profile = try await clientManager.account.getProfile(for: userDID)
            self.profilePictureURL = profile.avatarImageURL
            self.isLoadingProfile = false
            print("✅ Profile loaded, avatar URL: \(profile.avatarImageURL?.absoluteString ?? "none")")
        } catch {
            self.isLoadingProfile = false
            print("❌ Failed to load profile picture: \(error)")
        }
    }
    
    public func loadTimeline() async {
        guard let clientManager = self.clientManager else {
            print("❌ No clientManager available")
            return
        }
        
        guard let userDID, !userDID.isEmpty else {
            print("❌ No valid userDID available")
            return
        }
        
        isLoadingProfile = true
        
        do {
            // Always use the current user's DID for UserManager
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
            
            self.isLoadingProfile = false
            print("✅ User timeline loaded with \(authorFeed.feed.count) posts")
        } catch {
            self.isLoadingProfile = false
            print("❌ Failed to load user timeline: \(error)")
        }
    }
    
    public func loadProfile() async {
        guard let clientManager = self.clientManager else {
            print("❌ No clientManager available")
            return
        }
        
        guard let userDID, !userDID.isEmpty else {
            print("❌ No valid userDID available")
            return
        }
        
        isLoadingProfile = true
        
        do {
            // Always use the current user's DID for UserManager
            let profile = try await clientManager.account.getProfile(for: userDID)
            let authorFeed = try await clientManager.account.getAuthorFeed(by: userDID)
            
            // Update all properties
            self.profilePictureURL = profile.avatarImageURL
            self.bannerURL = profile.bannerImageURL
            self.follows = profile.followCount
            self.followers = profile.followerCount
            self.posts = profile.postCount
            self.name = profile.displayName
            self.handle = profile.actorHandle
            self.description = profile.description
            
            // Update timeline using PostModel
            userFeed.updatePosts(authorFeed.feed)
            timelineCursor = authorFeed.cursor
            
            self.isLoadingProfile = false
            print("✅ User profile and timeline loaded")
        } catch {
            self.isLoadingProfile = false
            print("❌ Failed to load user profile: \(error)")
        }
    }
    
    public func refreshProfile() async {
        timelineCursor = nil
        userFeed.clear()
        await loadProfile()
    }
    
    public func loadMorePosts() async {
        await loadTimeline()
    }
}

// MARK: - POST INTERACTION CONFORMANCE
extension UserManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        userFeed.findPost(by: postID)
    }
    
    func getPostState(postID: String) -> (isLiked: Bool, isReposted: Bool, likeCount: Int, repostCount: Int, replyCount: Int) {
        userFeed.getPostState(postID: postID)
    }
}
