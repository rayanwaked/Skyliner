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
    
    public private(set) var homeFeed: [AppBskyLexicon.Feed.GetTimelineOutput] = []
    public private(set) var authorFeed: [AppBskyLexicon.Feed.FeedViewPostDefinition] = []
    private var homeCursor: String?
    private var authorCursor: String?
    
    // MARK: - COMPUTED PROPERTIES
    var postData: [(postID: String, imageURL: URL?, name: String, handle: String, message: String)] {
        homeFeed.flatMap(\.feed).compactMap { feed in
            let author = feed.post.author
            let message = extractMessage(from: feed.post.record)
            
            return (
                postID: feed.post.uri,
                imageURL: author.avatarImageURL,
                name: author.displayName ?? author.actorHandle,
                handle: author.actorHandle,
                message: message
            )
        }
    }
    
    var authorData: [(postID: String, imageURL: URL?, name: String, handle: String, message: String)] {
        authorFeed.compactMap { feed in
            let author = feed.post.author
            let message = extractMessage(from: feed.post.record)
            
            return (
                postID: feed.post.uri,
                imageURL: author.avatarImageURL,
                name: author.displayName ?? author.actorHandle,
                handle: author.actorHandle,
                message: message
            )
        }
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
            homeFeed.append(feedResult)
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
            authorFeed = feedResult.feed
        }
    }
    
    // MARK: - REFRESH HOME FEED
    public func refreshPosts() async {
        homeCursor = nil
        homeFeed.removeAll()
        await loadPosts()
    }
    
    // MARK: - REFRESH AUTHOR FEED
    public func refreshAuthorPosts(shouldIncludePins: Bool = false) async {
        authorCursor = nil
        authorFeed = []
        await loadAuthorPosts(shouldIncludePins: shouldIncludePins)
    }
    
    // MARK: - CLEAR CACHE
    public func clearPostsCache() {
        homeFeed.removeAll()
        authorFeed = []
        homeCursor = nil
        authorCursor = nil
    }
}
