//
//  DataCoordinator.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import Foundation

@MainActor
class DataCoordinator {
    // MARK: - PROPERTIES
    private weak var appState: AppState?
    
    // MARK: - INITIALIZATION
    init(appState: AppState) {
        self.appState = appState
    }
    
    // MARK: - METHODS
    func refreshAllData() async {
//        guard let appState else { return }
    }
    
    func refreshPosts() async {
//        guard let appState else { return }
    }
}
