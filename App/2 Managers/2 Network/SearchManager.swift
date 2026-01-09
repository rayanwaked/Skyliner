//
//  SearchManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit

@MainActor
@Observable
// MARK: - MANAGER
public final class SearchManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    
    public let searchFeed = PostModel()
    
    private var currentCursor: String?
    private var currentQuery: String?
    
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
        
        await execute("Loading search results") {
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
    
    // MARK: - PRIVATE HELPERS
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
