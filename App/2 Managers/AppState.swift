//
//  AppState.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import ATProtoKit

@Observable
class AppState {
    // MARK: - PROPERTIES
    var clientManager: ClientManager?
    var config: ATProtocolConfiguration?
    let authManager = AuthManager()
    
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
                updateManagers(with: clientManager)
                
                if clientManager != nil {
                    await updateUserDID()
                    await dataCoordinator.refreshAllData()
                }
            }
        }
    }
    
    // MARK: - METHODS
    private func updateManagers(with clientManager: ClientManager?) {

    }

    private func updateUserDID() async {
        guard let storedUserDID = try? await clientManager?.account.getUserSession()?.sessionDID else {
            return
        }
        UserDefaults.standard.set(storedUserDID, forKey: "userDID")
    }
}

