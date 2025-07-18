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
public final class SearchManager {
    // MARK: - Properties
    @ObservationIgnored
    var clientManager: ClientManager?
    public private(set) var searchResults: [AppBskyLexicon.Feed.SearchPostsOutput] = []
    private var currentCursor: String?
    private var currentQuery: String?
    
    // MARK: - Computed Properties
    var postData: [(imageURL: URL?, name: String, handle: String, message: String)] {
        searchResults.flatMap(\.posts).compactMap { result in
            let author = result.author
            let message = extractMessage(from: result.record)
            
            return (
                imageURL: author.avatarImageURL,
                name: author.displayName ?? author.actorHandle,
                handle: author.actorHandle,
                message: message
            )
        }
    }
    
    // MARK: - Methods
    func searchBluesky(query: String) async {
        currentQuery = query
        currentCursor = nil
        searchResults = []
        
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
                searchResults.append(result)
            }
        } catch {
            print("Search error: \(error.localizedDescription)")
        }
    }
    
    func clearSearch() {
        searchResults = []
        currentCursor = nil
        currentQuery = nil
    }
    
    private func extractMessage(from record: UnknownType) -> String {
        let mirror = Mirror(reflecting: record)
        
        if let recordChild = mirror.children.first(where: { $0.label == "record" }),
           let postRecord = recordChild.value as? AppBskyLexicon.Feed.PostRecord {
            return postRecord.text
        }
        
        return "Unable to parse content"
    }
}
