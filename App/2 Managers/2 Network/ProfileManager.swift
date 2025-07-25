//
//  ProfileManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/24/25.
//

import SwiftUI
import ATProtoKit
import NukeUI

@MainActor
@Observable
public final class ProfileManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState? = nil
    var clientManager: ClientManager? { appState?.clientManager }
    var userDID: String
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
    public let profileFeed = PostModel()
    private var timelineCursor: String?
    
    // MARK: - COMPUTED PROPERTIES
    var postData: [(authorDID: String, postID: String, imageURL: URL?, name: String, handle: String, time: String, message: String, embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?)] {
        profileFeed.postData
    }
    
    // Legacy timeline property for backward compatibility
    var timeline: [AppBskyLexicon.Feed.FeedViewPostDefinition]? {
        profileFeed.posts.compactMap { $0.rawPost as? AppBskyLexicon.Feed.FeedViewPostDefinition }
    }
    
    // MARK: - INIT
    public init(userDID: String) {
        self.userDID = userDID
    }
    
    // MARK: - METHODS
    public func loadProfilePicture() async {
        guard let clientManager = self.clientManager else {
            print("❌ No clientManager available")
            return
        }
        
        guard !userDID.isEmpty else {
            print("❌ No valid userDID provided")
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
        
        guard !userDID.isEmpty else {
            print("❌ No valid userDID provided")
            return
        }
        
        isLoadingProfile = true
        
        do {
            let authorFeed = try await clientManager.account.getAuthorFeed(
                by: userDID,
                cursor: timelineCursor
            )
            timelineCursor = authorFeed.cursor
            
            if profileFeed.posts.isEmpty {
                profileFeed.updatePosts(authorFeed.feed)
            } else {
                profileFeed.appendPosts(authorFeed.feed)
            }
            
            self.isLoadingProfile = false
            print("✅ Timeline loaded with \(authorFeed.feed.count) posts")
        } catch {
            self.isLoadingProfile = false
            print("❌ Failed to load timeline: \(error)")
        }
    }
    
    public func loadProfile() async {
        guard let clientManager = self.clientManager else {
            print("❌ No clientManager available")
            return
        }
        
        guard !userDID.isEmpty else {
            print("❌ No valid userDID provided")
            return
        }
        
        isLoadingProfile = true
        
        do {
            // Make both async calls
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
            profileFeed.updatePosts(authorFeed.feed)
            timelineCursor = authorFeed.cursor
            
            self.isLoadingProfile = false
            print("✅ Profile and timeline loaded")
        } catch {
            self.isLoadingProfile = false
            print("❌ Failed to load profile: \(error)")
        }
    }
    
    public func refreshProfile() async {
        timelineCursor = nil
        profileFeed.clear()
        await loadProfile()
    }
    
    public func loadMorePosts() async {
        await loadTimeline()
    }
}

// MARK: - POST INTERACTION CONFORMANCE
extension ProfileManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        profileFeed.findPost(by: postID)
    }
    
    func getPostState(postID: String) -> (isLiked: Bool, isReposted: Bool, likeCount: Int, repostCount: Int, replyCount: Int) {
        profileFeed.getPostState(postID: postID)
    }
}
