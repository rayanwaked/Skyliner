//
//  ProfileManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/2/25.
//

// MARK: - IMPORTS
import SwiftUI
import ATProtoKit

// MARK: - POST MANAGER
@MainActor
@Observable
public class ProfileManager {
    private var contexts: [String: ProfileModel] = [:]
    public private(set) var profiles: [ProfileModel] = []
    @ObservationIgnored
    public var clientManager: ClientManager? = nil
}

// MARK: - PROFILE MANAGER FUNCTIONS
extension ProfileManager {
    // MARK: - FETCH CURRENT USER PROFILE
    /// Fetches the current user's profile using the current session DID, if available.
    public func fetchCurrentUserProfile() async -> [ProfileModel] {
        guard let configuration = clientManager?.configuration else {
            print("🍄⛔️ ProfileManager: No configuration available")
            return []
        }
        let manager = await ClientManager(configuration: configuration)
        self.clientManager = manager
        
        guard let sessionDID = try? await manager.protoClient.getUserSession()?.sessionDID else {
            print("🍄⛔️ ProfileManager: No session DID")
            return []
        }
        let did = sessionDID
        
        do {
            let detailed = try await manager.protoClient.getProfile(
                for: did
            )
            if let model = ProfileModel(from: detailed) {
                addOrUpdateProfile(from: detailed)
                return [model]
            } else {
                return []
            }
        } catch {
            print("🍄⛔️ ProfileManager: Failed to fetch user profile for DID \(did): \(error)")
            return []
        }
    }
    
    // MARK: - GET PROFILES
    // Populates the profiles array and contexts from an array of detailed definitions
    public func getProfiles(from detailedProfiles: [AppBskyLexicon.Actor.ProfileViewDetailedDefinition?]) {
        let validProfiles = detailedProfiles.compactMap { ProfileModel(from: $0) }
        self.profiles = validProfiles
        self.contexts = Dictionary(uniqueKeysWithValues: validProfiles.map { ($0.did, $0) })
    }
    
    // MARK: - ADD OR UPDATE PROFILE
    // Adds or updates a single profile from a detailed definition
    public func addOrUpdateProfile(from detailed: AppBskyLexicon.Actor.ProfileViewDetailedDefinition?) {
        guard let profile = ProfileModel(from: detailed) else { return }
        if let index = profiles.firstIndex(where: { $0.did == profile.did }) {
            profiles[index] = profile
        } else {
            profiles.append(profile)
        }
        contexts[profile.did] = profile
    }
    
    // MARK: - CLEAR PROFILES
    // Clears all profiles and contexts
    public func clearProfiles() {
        profiles.removeAll()
        contexts.removeAll()
    }
}
