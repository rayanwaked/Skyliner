//
//  AppState.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import ATProtoKit

@MainActor
@Observable
class AppState {
    // MARK: - PROPERTIES
    var clientManager: ClientManager?
    var config: ATProtocolConfiguration?
    let authManager = AuthManager()
    let accountManager = AccountManager()
    let trendsManager = TrendsManager()
    let postsManager = PostsManager()
    let searchManager = SearchManager()
    
    var dataCoordinator: DataCoordinator {
        DataCoordinator(appState: self)
    }
    
    private var storedUserDID: String {
        get { UserDefaults.standard.string(forKey: "userDID") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "userDID") }
    }

    var userDID: String? {
        storedUserDID.isEmpty ? nil : storedUserDID
    }
    
    // MARK: - INITIALIZATION
    init() {
        Task { @MainActor in
            for await clientManager in authManager.clientManagerUpdates {
                self.clientManager = clientManager
                self.config = clientManager?.credentials
                updateManagers(with: clientManager, with: self)
                
                // MARK: - FETCH ON LAUNCH
                if clientManager != nil {
                    await dataCoordinator.loadAllData()
                }
            }
        }
    }
    
    // MARK: - METHODS
    func updateManagers(with clientManager: ClientManager?, with appState: AppState?) {
        accountManager.appState = self
        trendsManager.clientManager = clientManager
        postsManager.appState = self
        searchManager.clientManager = clientManager
    }

    func updateUserDID() async {
        guard let storedUserDID = try? await clientManager?.account.getUserSession()?.sessionDID else {
            return
        }
        UserDefaults.standard.set(storedUserDID, forKey: "userDID")
    }
}

