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
    
    func loadAllData() async {
        await appState?.updateUserDID()
        await appState?.accountManager.loadProfilePicture()
        await appState?.trendsManager.loadTrends()
        await appState?.postsManager.loadPosts()
    }
}
