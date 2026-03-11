//
//  SearchManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit
import os.log

@MainActor
@Observable
// MARK: - MANAGER
public final class SearchManager: ManagedByAppState, OperationExecutor {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    
    public let searchFeed = PostModel()
    
    private var currentCursor: String?
    private var currentQuery: String?
    
    // MARK: - PROTOCOL CONFORMANCE
    var logger: Logger { AppLogger.search }
    
    // MARK: - COMPUTED PROPERTIES
    var searchPosts: [PostItem] { searchFeed.posts }
}

// MARK: - CORE FUNCTIONS
extension SearchManager {
    // MARK: - SEARCH BLUESKY
    func searchBluesky(query: String) async {
        // If it's a new query, reset everything
        if currentQuery != query {
            currentQuery = query
            currentCursor = nil
            searchFeed.clear()
        }
        
        await loadMoreResults()
    }
    
    // MARK: - LOAD MORE RESULTS
    func loadMoreResults() async {
        guard let query = currentQuery,
                !query.isEmpty,
              let clientManager else { return }
        
        _ = await executeVoid("Loading search results") {
            let result = try await clientManager.account.searchPosts(
                matching: query,
                author: nil,
                language: Locale(identifier: "en"),
                domain: nil,
                url: nil,
                limit: nil,
                cursor: currentCursor
            )
            
            // Update cursor for next pagination
            currentCursor = result.cursor
            
            // For initial search, replace posts; for pagination, append
            if searchFeed.posts.isEmpty {
                withAnimation(.snappy) {
                    searchFeed.updatePosts(result.posts)
                }
            } else {
                // Use duplicate-safe append method
                searchFeed.appendPostsWithDuplicateCheck(result.posts)
            }
        }
    }
    
    // MARK: - CLEAR SEARCH
    func clearSearch() {
        searchFeed.clear()
        currentCursor = nil
        currentQuery = nil
    }
}
