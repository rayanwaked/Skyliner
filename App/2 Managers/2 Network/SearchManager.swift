//
//  SearchManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import SwiftyBeaver
import ATProtoKit

// MARK: - SEARCH CONFIGURATION
struct SearchConfiguration {
    let author: String?
    let language: Locale?
    let domain: String?
    let url: String?
    let limit: Int?
    
    static let `default` = SearchConfiguration(
        author: nil,
        language: Locale(identifier: "en"),
        domain: nil,
        url: nil,
        limit: nil
    )
}

// MARK: - SEARCH STATE
struct SearchState {
    var query: String?
    var cursor: String?
    var isLoading = false
    var error: SearchError?
    var hasResults: Bool = false
}

// MARK: - SEARCH MANAGER
@MainActor
@Observable
public final class SearchManager {
    // MARK: - DEPENDENCIES
    @ObservationIgnored
    var clientManager: ClientManager? { appState?.clientManager }
    @ObservationIgnored
    var appState: AppState?
    
    // MARK: - MODELS
    public let searchFeed = PostModel()
    
    // MARK: - CONFIGURATION
    private var configuration: SearchConfiguration = .default
    
    // MARK: - STATE
    private(set) var state = SearchState()
    
    // MARK: - COMPUTED PROPERTIES
    var searchPosts: [PostItem] { searchFeed.posts }
    var isLoading: Bool { state.isLoading }
    var hasResults: Bool { state.hasResults }
    var currentQuery: String? { state.query }
    var error: SearchError? { state.error }
    
    // MARK: - INIT
    init(
        configuration: SearchConfiguration = .default,
        appState: AppState? = nil
    ) {
        self.configuration = configuration
        self.appState = appState
    }
}

// MARK: - PUBLIC INTERFACE
extension SearchManager {
    func configure(with appState: AppState) {
        self.appState = appState
    }
    
    func updateConfiguration(_ configuration: SearchConfiguration) {
        self.configuration = configuration
    }
    
    func searchBluesky(query: String) async {
        let isNewQuery = state.query != query
        
        if isNewQuery {
            resetSearchState(for: query)
        }
        
        await performSearch(isInitial: isNewQuery)
    }
    
    func loadMoreResults() async {
        guard !state.isLoading,
              state.query != nil,
              state.cursor != nil else { return }
        
        await performSearch(isInitial: false)
    }
    
    func clearSearch() {
        searchFeed.clear()
        state = SearchState()
    }
}

// MARK: - PRIVATE OPERATIONS
private extension SearchManager {
    func resetSearchState(for query: String) {
        state.query = query
        state.cursor = nil
        state.hasResults = false
        searchFeed.clear()
    }
    
    func performSearch(isInitial: Bool) async {
        await withLoadingState {
            try await executeSearch(isInitial: isInitial)
        }
    }
    
    func executeSearch(isInitial: Bool) async throws {
        guard let query = state.query,
              !query.isEmpty,
              let clientManager = clientManager else {
            throw SearchError.invalidConfiguration
        }
        
        let result = try await clientManager.account.searchPosts(
            matching: query,
            author: configuration.author,
            language: configuration.language,
            domain: configuration.domain,
            url: configuration.url,
            limit: configuration.limit,
            cursor: state.cursor
        )
        
        updateSearchResults(result, isInitial: isInitial)
    }
    
    func updateSearchResults(_ result: AppBskyLexicon.Feed.SearchPostsOutput, isInitial: Bool) {
        state.cursor = result.cursor
        state.hasResults = !result.posts.isEmpty || !searchFeed.posts.isEmpty
        
        if isInitial {
            withAnimation(.snappy) {
                searchFeed.updatePosts(result.posts)
            }
        } else {
            searchFeed.appendPostsWithDuplicateCheck(result.posts)
        }
    }
    
    func withLoadingState<T>(_ operation: () async throws -> T) async -> T? {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }
        
        do {
            return try await operation()
        } catch let error as SearchError {
            state.error = error
            log.error("Operation failed: \(error)")
            return nil
        } catch {
            let searchError = SearchError.searchFailed(error)
            state.error = searchError
            log.error("Operation failed: \(searchError)")
            return nil
        }
    }
}

// MARK: - ERRORS
enum SearchError: LocalizedError {
    case clientUnavailable
    case invalidConfiguration
    case searchFailed(Error)
    case emptyQuery
    
    var errorDescription: String? {
        switch self {
        case .clientUnavailable:
            return "Client manager is not available"
        case .invalidConfiguration:
            return "Invalid search configuration"
        case .searchFailed(let error):
            return "Search failed: \(error.localizedDescription)"
        case .emptyQuery:
            return "Search query cannot be empty"
        }
    }
}
