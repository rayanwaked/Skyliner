//
//  TrendsManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import SwiftyBeaver
import ATProtoKit

// MARK: - TREND ITEM
struct TrendItem: Identifiable, Hashable {
    let id: String
    let displayName: String
    let count: Int?
    
    init(displayName: String, count: Int? = nil) {
        self.id = displayName
        self.displayName = displayName
        self.count = count
    }
}

// MARK: - TRENDS STATE
struct TrendsState {
    var items: [TrendItem] = []
    var isLoading = false
    var error: TrendError?
}

// MARK: - TRENDS MANAGER
@MainActor
@Observable
public final class TrendsManager {
    // MARK: - DEPENDENCIES
    @ObservationIgnored
    var appState: AppState?
    private var clientManager: ClientManager? { appState?.clientManager }
    
    // MARK: - STATE
    private(set) var state = TrendsState()
    
    // MARK: - COMPUTED PROPERTIES
    var trends: [TrendItem] { state.items }
    var isLoading: Bool { state.isLoading }
    var error: TrendError? { state.error }
    
    // MARK: - INITALIZATION
    init(appState: AppState? = nil) {
        self.appState = appState
    }
}

// MARK: - PUBLIC INTERFACE
extension TrendsManager {
    func configure(with appState: AppState) {
        self.appState = appState
    }
    
    func loadTrends() async {
        await withLoadingState {
            try await performLoadTrends()
        }
    }
    
    func refreshTrends() async {
        await loadTrends()
    }
}

// MARK: - PRIVATE OPERATIONS
private extension TrendsManager {
    func performLoadTrends() async throws {
        guard let clientManager = clientManager else {
            throw TrendError.clientUnavailable
        }
        
        let output = try await clientManager.account.getTrends()
        
        let trendItems = output.trends.map { trend in
            TrendItem(displayName: trend.displayName)
        }
        
        state.items = trendItems
    }
    
    func withLoadingState<T>(_ operation: () async throws -> T) async -> T? {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }
        
        do {
            return try await operation()
        } catch let error as TrendError {
            state.error = error
            log.error("Operation failed: \(error)")
            return nil
        } catch {
            let trendError = TrendError.loadingFailed(error)
            state.error = trendError
            log.error("Operation failed: \(trendError)")
            return nil
        }
    }
}

// MARK: - ERRORS
enum TrendError: LocalizedError {
    case clientUnavailable
    case loadingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .clientUnavailable:
            return "Client manager is not available"
        case .loadingFailed(let error):
            return "Failed to load trends: \(error.localizedDescription)"
        }
    }
}
