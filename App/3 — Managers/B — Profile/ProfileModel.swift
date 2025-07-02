//
//  ProfileModel.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - IMPORTS
import ATProtoKit
import Foundation

// MARK: - PROFILE MODEL
public struct ProfileModel: @MainActor Codable, Equatable, Sendable {
    public let did: String
    public let handle: String
    public let displayName: String?
    public let description: String?
    public let avatar: URL?
    public let banner: URL?
    public let followerCount: Int?
    public let followCount: Int?
    public let postCount: Int?
    public let associated: AppBskyLexicon.Actor.ProfileAssociatedDefinition?
    public let joinedViaStarterPack: AppBskyLexicon.Graph.StarterPackViewBasicDefinition?
    public let indexedAt: Date?
    public let createdAt: Date?
    public let viewer: AppBskyLexicon.Actor.ViewerStateDefinition?
    public let labels: [ComAtprotoLexicon.Label.LabelDefinition]?
    public let pinnedPost: ComAtprotoLexicon.Repository.StrongReference?
    public let verificationState: AppBskyLexicon.Actor.VerificationStateDefinition?
    public let status: AppBskyLexicon.Actor.StatusViewDefinition?

    public init?(from detailed: AppBskyLexicon.Actor.ProfileViewDetailedDefinition?) {
        guard let detailed else { return nil }
        self.did = detailed.actorDID
        self.handle = detailed.actorHandle
        self.displayName = detailed.displayName
        self.description = detailed.description
        self.avatar = detailed.avatarImageURL
        self.banner = detailed.bannerImageURL
        self.followerCount = detailed.followerCount
        self.followCount = detailed.followCount
        self.postCount = detailed.postCount
        self.associated = detailed.associated
        self.joinedViaStarterPack = detailed.joinedViaStarterPack
        self.indexedAt = detailed.indexedAt
        self.createdAt = detailed.createdAt
        self.viewer = detailed.viewer
        self.labels = detailed.labels
        self.pinnedPost = detailed.pinnedPost
        self.verificationState = detailed.verificationState
        self.status = detailed.status
    }
}

// MARK: - PROFILE
public struct Profile: @MainActor Codable, Hashable, Sendable {
  public let did: String
  public let handle: String
  public let displayName: String?
  public let avatarImageURL: URL?

  public init(
    did: String,
    handle: String,
    displayName: String?,
    avatarImageURL: URL?
  ) {
    self.did = did
    self.handle = handle
    self.displayName = displayName
    self.avatarImageURL = avatarImageURL
  }
}

// MARK: - PROFILE VIEW DETAILED DEFINITION EXTENSION
extension AppBskyLexicon.Actor.ProfileViewDetailedDefinition {
  public var profile: Profile {
    Profile(
      did: actorDID,
      handle: actorHandle,
      displayName: displayName,
      avatarImageURL: avatarImageURL
    )
  }
}

// MARK: PROFILE MODEL PLACEHOLDERS
extension ProfileModel {
    public static let placeholders: [ProfileModel] = [
        ProfileModel(from: AppBskyLexicon.Actor.ProfileViewDetailedDefinition(
            actorDID: "placeholder1",
            actorHandle: "placeholder1@bsky",
            displayName: "Placeholder One",
            description: "This is a placeholder profile.",
            avatarImageURL: nil,
            bannerImageURL: nil,
            followerCount: 42,
            followCount: 7,
            postCount: 3,
            associated: nil,
            joinedViaStarterPack: nil,
            indexedAt: nil,
            createdAt: nil,
            viewer: nil,
            labels: nil,
            pinnedPost: nil,
            verificationState: nil,
            status: nil
        )),
        ProfileModel(from: AppBskyLexicon.Actor.ProfileViewDetailedDefinition(
            actorDID: "placeholder2",
            actorHandle: "placeholder2@bsky",
            displayName: "Placeholder Two",
            description: "Another sample placeholder profile.",
            avatarImageURL: nil,
            bannerImageURL: nil,
            followerCount: 13,
            followCount: 2,
            postCount: 1,
            associated: nil,
            joinedViaStarterPack: nil,
            indexedAt: nil,
            createdAt: nil,
            viewer: nil,
            labels: nil,
            pinnedPost: nil,
            verificationState: nil,
            status: nil
        ))
    ].compactMap { $0 }
}
