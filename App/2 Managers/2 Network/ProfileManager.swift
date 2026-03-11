//
//  ProfileManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/24/25.
//

import SwiftUI
import ATProtoKit
import NukeUI
import os.log

@MainActor
@Observable
// MARK: - MANAGER
public final class ProfileManager: ProfileDataProvider, OperationExecutor {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var userDID: String
    var profilePictureURL: URL?
    var bannerURL: URL?
    var follows: Int?
    var followers: Int?
    var posts: Int?
    var description: String?
    var name: String?
    var handle: String?
    var isLoadingProfile = false
    var timelineCursor: String?
    
    public let profileFeed = PostModel()
    
    // MARK: - PROTOCOL CONFORMANCE
    var logger: Logger { AppLogger.profile }
    var feed: PostModel { profileFeed }
    
    // MARK: - COMPUTED PROPERTIES
    var profilePosts: [PostItem] { profileFeed.posts }
    
    // MARK: - INIT
    public init(userDID: String) {
        self.userDID = userDID
    }
}

// MARK: - POST INTERACTION CONFORMANCE
extension ProfileManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        profileFeed.findPost(by: postID)
    }
}

// MARK: - MANAGED BY APPSTATE CONFORMANCE
extension ProfileManager: ManagedByAppState {}
