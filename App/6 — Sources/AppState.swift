//
//  AppState.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import ATProtoKit

// MARK: - App State
@Observable
class AppState {
    var configuration: ATProtocolConfiguration? {
        didSet {
            if let configuration {
                Task { @MainActor in
                    self.clientManager = await ClientManager(configuration: configuration)
                }
            } else {
                clientManager = nil
            }
        }
    }
    
    init() {
        Task {
            for await configuration in authenticationManager.configurationUpdates {
                self.configuration = configuration
            }
        }
    }
    
    var clientManager: ClientManager? = nil
    var authenticationManager = AuthenticationManager()
}
