//
//  TrendsManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit

@MainActor
@Observable
// MARK: - MANAGER
public final class TrendsManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    var trends: [String] = []
    
    // MARK: - METHODS
    public func loadTrends() async {
        do {
            let output = try await clientManager?.account.getTrends()
            trends = output?.trends.map { $0.displayName } ?? []
        } catch {
            return print(error.localizedDescription)
        }
    }
}
