//
//  ProfilesManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/14/25.
//

import SwiftUI
import ATProtoKit

@MainActor
// MARK: - MANAGER
public final class ProfilesManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    var profiles: [String: String] = [:]
}
