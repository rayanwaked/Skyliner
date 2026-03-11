//
//  BaseProfileManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 3/11/26.
//

import SwiftUI
import ATProtoKit
import os.log

// MARK: - PROFILE DATA PROTOCOL
@MainActor
protocol ProfileDataProvider: AnyObject, ManagedByAppState, OperationExecutor {
    var profilePictureURL: URL? { get set }
    var bannerURL: URL? { get set }
    var follows: Int? { get set }
    var followers: Int? { get set }
    var posts: Int? { get set }
    var description: String? { get set }
    var name: String? { get set }
    var handle: String? { get set }
    var isLoadingProfile: Bool { get set }
    var timelineCursor: String? { get set }
    
    var userDID: String { get }
    var feed: PostModel { get }
}

// MARK: - DEFAULT IMPLEMENTATIONS
extension ProfileDataProvider {
    // MARK: - LOAD PROFILE PICTURE
    func loadProfilePicture() async {
        guard let clientManager, !userDID.isEmpty else {
            logger.warning("No clientManager or userDID available")
            return
        }
        
        _ = await executeVoid("Loading profile picture") {
            isLoadingProfile = true
            defer { isLoadingProfile = false }
            let profile = try await clientManager.account.getProfile(for: userDID)
            profilePictureURL = profile.avatarImageURL
        }
    }
    
    // MARK: - LOAD TIMELINE
    func loadTimeline() async {
        guard let clientManager, !userDID.isEmpty else {
            logger.warning("No clientManager or userDID available")
            return
        }
        
        _ = await executeVoid("Loading timeline") {
            isLoadingProfile = true
            defer { isLoadingProfile = false }
            let authorFeed = try await clientManager.account.getAuthorFeed(
                by: userDID,
                cursor: timelineCursor
            )
            timelineCursor = authorFeed.cursor
            
            if feed.posts.isEmpty {
                feed.updatePosts(authorFeed.feed)
            } else {
                feed.appendPosts(authorFeed.feed)
            }
        }
    }
    
    // MARK: - LOAD PROFILE
    func loadProfile() async {
        guard let clientManager, !userDID.isEmpty else {
            logger.warning("No clientManager or userDID available")
            return
        }
        
        _ = await executeVoid("Loading profile") {
            isLoadingProfile = true
            defer { isLoadingProfile = false }
            let profile = try await clientManager.account.getProfile(for: userDID)
            let authorFeed = try await clientManager.account.getAuthorFeed(by: userDID)
            
            updateProfile(from: profile)
            feed.updatePosts(authorFeed.feed)
            timelineCursor = authorFeed.cursor
        }
    }
    
    // MARK: - REFRESH PROFILE
    func refreshProfile() async {
        timelineCursor = nil
        feed.clear()
        await loadProfile()
    }
    
    // MARK: - LOAD MORE POSTS
    func loadMorePosts() async {
        await loadTimeline()
    }
    
    // MARK: - UPDATE PROFILE
    func updateProfile(from profile: AppBskyLexicon.Actor.ProfileViewDetailedDefinition) {
        profilePictureURL = profile.avatarImageURL
        bannerURL = profile.bannerImageURL
        follows = profile.followCount
        followers = profile.followerCount
        posts = profile.postCount
        name = profile.displayName
        handle = profile.actorHandle
        description = profile.description
    }
}
