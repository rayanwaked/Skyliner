//
//  AccountManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit
import NukeUI

@MainActor
@Observable
public final class AccountManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState? = nil
    var profilePictureURL: URL? = nil
    var isLoadingProfile = false
    
    // MARK: - METHODS
    public func loadProfilePicture() async {
        guard let clientManager = self.appState?.clientManager else {
            print("❌ No clientManager available")
            return
        }
        
        guard let userDID = appState?.userDID, !userDID.isEmpty else {
            print("❌ No valid userDID available")
            return
        }
        
        isLoadingProfile = true
        
        do {
            let profile = try await clientManager.account.getProfile(for: userDID)
            await MainActor.run {
                self.profilePictureURL = profile.avatarImageURL
                self.isLoadingProfile = false
            }
            print("✅ Profile loaded, avatar URL: \(profile.avatarImageURL?.absoluteString ?? "none")")
        } catch {
            await MainActor.run {
                self.isLoadingProfile = false
            }
            print("❌ Failed to load profile picture: \(error)")
        }
    }
}

