//
//  FeedModel.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - IMPORTS
import ATProtoKit
import Foundation

// MARK: - FEED MODEL
public struct FeedModel: @MainActor Codable, Equatable, Identifiable, Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(uri)
  }

  public var id: String { uri }
  public let uri: String
  public let displayName: String
  public let description: String?
  public let avatarImageURL: URL?
  public let creatorHandle: String

  public init(
    uri: String,
    displayName: String,
    description: String?,
    avatarImageURL: URL?,
    creatorHandle: String,
  ) {
    self.uri = uri
    self.displayName = displayName
    self.description = description
    self.avatarImageURL = avatarImageURL
    self.creatorHandle = creatorHandle
  }
}

// MARK: - GENERATOR VIEW DEFINITION EXTENSION
extension AppBskyLexicon.Feed.GeneratorViewDefinition {
  public var feedModel: FeedModel {
      FeedModel(
      uri: feedURI,
      displayName: displayName,
      description: description,
      avatarImageURL: avatarImageURL,
      creatorHandle: creator.actorHandle
    )
  }
}

// MARK: - FEED MODEL PREVIEW PLACEHOLDERS
extension FeedModel {
    public static let placeholders: [FeedModel] = [
        FeedModel(
            uri: "feed://explore",
            displayName: "Explore",
            description: "Discover trending topics and new creators.",
            avatarImageURL: nil,
            creatorHandle: "skyliner"
        ),
        FeedModel(
            uri: "feed://tech",
            displayName: "Tech News",
            description: "Latest updates in technology and coding.",
            avatarImageURL: nil,
            creatorHandle: "techguru"
        ),
        FeedModel(
            uri: "feed://funny",
            displayName: "Funny",
            description: "Memes, jokes, and more to brighten your day!",
            avatarImageURL: nil,
            creatorHandle: "gigglebot"
        )
    ]
}
