//
//  AppState.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import ATProtoKit

// MARK: - APP STATE
@MainActor
@Observable
public class AppState {
    // MARK: - PROPERTIES
    var clientManager: ClientManager?
    var config: ATProtocolConfiguration?
    let authManager = AuthManager()
    let userManager = UserManager()
    let profileManager = ProfileManager(userDID: "")
    let trendsManager = TrendsManager()
    let postManager = PostManager()
    let searchManager = SearchManager()
    let notificationsManager = NotificationsManager()
    let threadManager = ThreadManager()

    private var storedUserDID: String {
        get { UserDefaults.standard.string(forKey: "userDID") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "userDID") }
    }

    var userDID: String? {
        storedUserDID.isEmpty ? nil : storedUserDID
    }

    private var storedShowingTrends: Bool {
        get { UserDefaults.standard.object(forKey: "showingTrends") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "showingTrends") }
    }
    var showingTrends: Bool {
        get { storedShowingTrends }
        set { storedShowingTrends = newValue }
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
                    await loadAllData()
                }
            }
        }
    }

    // MARK: - METHODS
    func updateManagers(with clientManager: ClientManager?, with appState: AppState?) {
        userManager.appState = self
        profileManager.appState = self
        trendsManager.appState = self
        postManager.appState = self
        searchManager.appState = self
        notificationsManager.appState = self
        threadManager.appState = self
    }

    func loadAllData() async {
        await updateUserDID()
        await userManager.loadProfile()
        await trendsManager.loadTrends()
        await postManager.loadPosts()
        await notificationsManager.loadNotifications()
    }
    
    func updateUserDID() async {
        guard let storedUserDID = try? await clientManager?.account.getUserSession()?.sessionDID else {
            return
        }
        UserDefaults.standard.set(storedUserDID, forKey: "userDID")
    }
}

