//
//  TrendsManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit

@Observable
public final class TrendsManager {
    @ObservationIgnored
    var clientManager: ClientManager? = nil
    
    var trends: [String] = []
    
    public func loadTrends() async {
        do {
            let output = try await clientManager?.account.getTrends()
            trends = output?.trends.map { $0.displayName } ?? []
        } catch {
            return print(error.localizedDescription)
        }
    }
}

