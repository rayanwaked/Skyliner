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
    
    // Unified feed
    public let searchFeed = PostModel()
    
    // Raw data for pagination
    private var rawSearchResults: [AppBskyLexicon.Feed.SearchPostsOutput] = []
    private var currentCursor: String?
    private var currentQuery: String?
    
    // MARK: - COMPUTED PROPERTIES
    var postData: [(authorDID: String, postID: String, imageURL: URL?, name: String, handle: String, time: String, message: String, embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?)] {
        searchFeed.postData
    }
    
    var searchResults: [AppBskyLexicon.Feed.SearchPostsOutput] {
        rawSearchResults
    }
    
    // MARK: - METHODS
    func searchBluesky(query: String) async {
        // Only clear if this is a new query
        if currentQuery != query {
            currentQuery = query
            currentCursor = nil
            rawSearchResults = []
            searchFeed.clear()
        }
        
        await loadMoreResults()
    }
    
    func loadMoreResults() async {
        guard let query = currentQuery else { return }
        
        do {
            let result = try await clientManager?.account.searchPosts(
                matching: query,
                author: nil,
                language: Locale(identifier: "en"),
                domain: nil,
                url: nil,
                limit: nil,
                cursor: currentCursor
            )
            
            if let result {
                currentCursor = result.cursor
                withAnimation(.snappy) {
                    if rawSearchResults.isEmpty {
                        rawSearchResults = [result]
                        searchFeed.updatePosts(result.posts)
                    } else {
                        rawSearchResults.append(result)
                        searchFeed.appendPosts(result.posts)
                    }
                }
            }
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
    
    func clearSearch() {
        rawSearchResults = []
        searchFeed.clear()
        currentCursor = nil
        currentQuery = nil
    }
}
