//
//  PostManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

import SwiftUI
import ATProtoKit

@MainActor
@Observable
// MARK: - MANAGER
public final class PostManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    var userDID: String? { appState?.userDID }
    
    // Unified feeds
    public let homeFeed = PostModel()
    public let authorFeed = PostModel()
    
    // Raw data storage for pagination
    private var rawHomeFeed: [AppBskyLexicon.Feed.GetTimelineOutput] = []
    private var homeCursor: String?
    private var authorCursor: String?
    
    // MARK: - COMPUTED PROPERTIES
    var postData: [(postID: String, imageURL: URL?, name: String, handle: String, message: String)] {
        homeFeed.postData
    }
    
    var authorData: [(postID: String, imageURL: URL?, name: String, handle: String, message: String)] {
        authorFeed.postData
    }
}

// MARK: - CORE FUNCTIONS
extension PostManager {
    // MARK: - LOAD POSTS
    func loadPosts() async {
        guard let userDID, !userDID.isEmpty else {
            logError("No valid userDID available")
            return
        }
        guard let clientManager else {
            logError("No valid client manager available")
            return
        }
        
        await execute("Loading posts") {
            let feedResult = try await clientManager.account.getTimeline(using: userDID, cursor: homeCursor)
            homeCursor = feedResult.cursor
            rawHomeFeed.append(feedResult)
            
            // Update unified feed with all posts
            let allPosts = rawHomeFeed.flatMap(\.feed)
            homeFeed.updatePosts(allPosts)
        }
    }
    
    // MARK: - GET AUTHOR POSTS
    public func loadAuthorPosts(shouldIncludePins: Bool) async {
        guard let clientManager else {
            logError("No valid client manager available")
            return
        }
        
        await execute("Getting author feed") {
            let feedResult = try await clientManager.account.getAuthorFeed(
                by: appState?.userDID ?? "",
                limit: nil,
                cursor: authorCursor,
                postFilter: nil,
                shouldIncludePins: shouldIncludePins
            )
            
            authorCursor = feedResult.cursor
            authorFeed.appendPosts(feedResult.feed)
        }
    }
    
    // MARK: - REFRESH HOME FEED
    public func refreshPosts() async {
        homeCursor = nil
        let oldRawFeed = rawHomeFeed
        rawHomeFeed = []
        homeFeed.clear()
        
        await loadPosts()
        
        // Restore if failed
        if homeFeed.posts.isEmpty {
            rawHomeFeed = oldRawFeed
            let allPosts = rawHomeFeed.flatMap(\.feed)
            homeFeed.updatePosts(allPosts)
        }
    }
    
    // MARK: - REFRESH AUTHOR FEED
    public func refreshAuthorPosts(shouldIncludePins: Bool = false) async {
        authorCursor = nil
        let oldFeed = authorFeed.posts
        authorFeed.clear()
        
        await loadAuthorPosts(shouldIncludePins: shouldIncludePins)
        
        // Restore if failed (this is simplified - you might want to store raw data)
        if authorFeed.posts.isEmpty {
            // You'd need to implement restoration logic here if needed
        }
    }
}
