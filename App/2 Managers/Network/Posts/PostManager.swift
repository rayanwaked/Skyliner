//
//  PostManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

import SwiftUI
import ATProtoKit
import SwiftyBeaver

@MainActor
@Observable
// MARK: - MANAGER
public final class PostManager {
    // MARK: - PROP ERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    var userDID: String? { appState?.userDID }
    
    public let homeFeed = PostModel()
    public let authorFeed = PostModel()
    
    private var homeCursor: String?
    private var authorCursor: String?
    
    // MARK: - COMPUTED PROPERTIES
    var homePosts: [PostItem] { homeFeed.posts }
    var authorPosts: [PostItem] { authorFeed.posts }
}

// MARK: - CORE FUNCTIONS
extension PostManager {
    // MARK: - LOAD POSTS
    func loadPosts() async {
        guard let userDID, !userDID.isEmpty else {
            log.error("No valid userDID available")
            return
        }
        guard let clientManager else {
            log.error("No valid client manager available")
            return
        }
        
        await execute("Loading posts") {
            let feedResult = try await clientManager.account.getTimeline(using: userDID, cursor: homeCursor)
            
            // Update cursor for next pagination
            homeCursor = feedResult.cursor
            
            // For initial load, replace posts; for pagination, append with duplicate check
            if homeFeed.posts.isEmpty {
                homeFeed.updatePosts(feedResult.feed)
            } else {
                homeFeed.appendPostsWithDuplicateCheck(feedResult.feed)
            }
        }
    }
    
    // MARK: - GET AUTHOR POSTS
    public func loadAuthorPosts(shouldIncludePins: Bool) async {
        guard let clientManager else {
            log.error("No valid client manager available")
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
            
            // For initial load, replace posts; for pagination, append with duplicate check
            if authorFeed.posts.isEmpty {
                authorFeed.updatePosts(feedResult.feed)
            } else {
                authorFeed.appendPostsWithDuplicateCheck(feedResult.feed)
            }
        }
    }
    
    // MARK: - REFRESH HOME FEED
    public func refreshPosts() async {
        // Reset cursor and clear existing data
        homeCursor = nil
        homeFeed.clear()
        
        // Load fresh data
        await loadPosts()
    }
    
    // MARK: - REFRESH AUTHOR FEED
    public func refreshAuthorPosts(shouldIncludePins: Bool = false) async {
        // Reset cursor and clear existing data
        authorCursor = nil
        authorFeed.clear()
        
        await loadAuthorPosts(shouldIncludePins: shouldIncludePins)
    }
    
    private func execute(_ operationName: String, operation: () async throws -> Void) async {
        do {
            try await operation()
            log.info("\(operationName) completed successfully")
        } catch {
            log.error("Failed to \(operationName.lowercased()): \(error.localizedDescription)")
        }
    }
}
