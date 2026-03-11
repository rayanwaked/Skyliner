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
    // MARK: - CONSTANTS
    private static let defaultPageSize = 30
    private static let maxPageSize = 50
    
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    var userDID: String? { appState?.userDID }
    
    public let homeFeed = PostModel()
    public let authorFeed = PostModel()
    
    private var homeCursor: String?
    private var authorCursor: String?
    private var isLoadingHome = false
    private var isLoadingAuthor = false
    
    // MARK: - COMPUTED PROPERTIES
    var homePosts: [PostItem] { homeFeed.posts }
    var authorPosts: [PostItem] { authorFeed.posts }
}

// MARK: - CORE FUNCTIONS
extension PostManager {
    // MARK: - LOAD POSTS
    func loadPosts() async {
        // Prevent concurrent loads
        guard !isLoadingHome else { return }
        
        guard let userDID, !userDID.isEmpty else {
            logError("No valid userDID available")
            return
        }
        guard let clientManager else {
            logError("No valid client manager available")
            return
        }
        
        isLoadingHome = true
        defer { isLoadingHome = false }
        
        await execute("Loading posts") {
            let feedResult = try await clientManager.account.getTimeline(
                using: userDID,
                limit: Self.defaultPageSize,
                cursor: homeCursor
            )
            
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
        // Prevent concurrent loads
        guard !isLoadingAuthor else { return }
        
        guard let clientManager else {
            logError("No valid client manager available")
            return
        }
        
        isLoadingAuthor = true
        defer { isLoadingAuthor = false }
        
        await execute("Getting author feed") {
            let feedResult = try await clientManager.account.getAuthorFeed(
                by: appState?.userDID ?? "",
                limit: Self.defaultPageSize,
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
}
