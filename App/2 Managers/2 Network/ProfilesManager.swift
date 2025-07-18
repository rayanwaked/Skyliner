//
//  ProfilesManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/14/25.
//

import SwiftUI
import ATProtoKit

@MainActor
public final class ProfilesManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var clientManager: ClientManager? = nil
    var profiles: [String: String] = [:]
}
