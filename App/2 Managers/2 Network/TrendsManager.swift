//
//  TrendsManager.swift
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
public final class TrendsManager: ManagedByAppState {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var trends: [String] = []
    var isLoading = false
    var lastError: AppError?

    // MARK: - METHODS
    public func loadTrends() async {
        guard let clientManager else {
            AppLogger.trends.warning("No clientManager available for loading trends")
            return
        }
        
        isLoading = true
        lastError = nil
        
        do {
            let output = try await clientManager.account.getTrends()
            trends = output.trends.map { $0.displayName }
            AppLogger.trends.info("Loaded \(self.trends.count) trends")
        } catch {
            lastError = .network(underlying: error)
            AppLogger.trends.error("Failed to load trends: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

