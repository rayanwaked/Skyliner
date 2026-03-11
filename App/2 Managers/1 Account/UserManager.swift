//
//  UserManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit
import NukeUI
import os.log

@MainActor
@Observable
// MARK: - MANAGER
public final class UserManager: ProfileDataProvider, OperationExecutor {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
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
    
    public let userFeed = PostModel()
    
    // MARK: - PROTOCOL CONFORMANCE
    var logger: Logger { AppLogger.profile }
    var userDID: String { appState?.userDID ?? "" }
    var feed: PostModel { userFeed }
    
    // MARK: - COMPUTED PROPERTIES
    var userPosts: [PostItem] { userFeed.posts }
}

// MARK: - POST INTERACTION CONFORMANCE
extension UserManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        userFeed.findPost(by: postID)
    }
}

// MARK: - MANAGED BY APPSTATE CONFORMANCE
extension UserManager: ManagedByAppState {}
