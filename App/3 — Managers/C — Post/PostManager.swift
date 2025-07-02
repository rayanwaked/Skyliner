//
//  PostManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - IMPORTS
import SwiftUI
import ATProtoKit

// MARK: - POST MANAGER
@MainActor
@Observable
public class PostManager {
  @ObservationIgnored
  private var contexts: [String: PostContextModel] = [:]
  
  @ObservationIgnored
  public private(set) var posts: [PostModel] = []
  @ObservationIgnored
  public private(set) var clientManager: ClientManager? = nil
  @ObservationIgnored
  public var configuration: ATProtocolConfiguration?
  
  public init() {}
  public init(configuration: ATProtocolConfiguration? = nil) {
    self.configuration = configuration
  }

    public func get(for post: PostModel, client: ClientManager) -> PostContextModel {
        if let context = contexts[post.uri] {
            return context
        } else {
            let context = PostContextModel(post: post, client: client)
            contexts[post.uri] = context
            return context
        }
    }

    public func getFeed() async -> [PostModel] {
        guard let configuration = configuration else {
            print("PostManager.getFeed() returning early: configuration is nil")
            return []
        }
        let client = await ATProtoKit(sessionConfiguration: configuration)
        let manager = await Skyliner.ClientManager(configuration: configuration)
        guard let timeline = try? await client.getTimeline() else {
            print("Error fetching feed: could not get timeline")
            return []
        }
        posts = timeline.feed.compactMap { $0.postModel }
        clientManager = manager
        return posts
      }
}

// MARK: - POST CONTEXT MODEL
@MainActor
@Observable
public final class PostContextModel: Sendable {
  private var post: PostModel
  private let client: ClientManager

  public var isLiked: Bool { likeURI != nil }
  public var isReposted: Bool { repostURI != nil }

  public var likeCount: Int { post.likeCount + (isLiked ? 1 : 0) }
  public var repostCount: Int { post.repostCount + (isReposted ? 1 : 0) }

  private var likeURI: String?
  private var repostURI: String?

  public init(post: PostModel, client: ClientManager) {
    self.post = post
    self.client = client

    likeURI = post.likeURI
    repostURI = post.repostURI
  }

  public func update(with post: PostModel) {
    self.post = post

    likeURI = post.likeURI
    repostURI = post.repostURI
  }

  public func toggleLike() async {
    let previousState = likeURI
    do {
      if let likeURI {
        self.likeURI = nil
        try await client.blueskyClient.deleteRecord(.recordURI(atURI: likeURI))
      } else {
        self.likeURI = "ui.optimistic.like"
        self.likeURI = try await client.blueskyClient.createLikeRecord(
          .init(recordURI: post.uri, cidHash: post.cid)
        ).recordURI
      }
    } catch {
      self.likeURI = previousState
    }
  }

//  public func toggleRepost() async {
//    // TODO: IMPLEMENT
//      let previousState = repostURI
//      do {
//          if let repostURI {
//              self.repostURI = nil
//              try await client.blueskyClient.deleteRecord(.recordURI(atURI: repostURI))
//          } else {
//              self.repostURI = "ui.optimistic.repost"
//              self.repostURI = try await client.blueskyClient.createRepostRecord(
//                .init(recordURI: post.uri, cidHash: post.cid
//                     ).recordURI
//          }
//      } catch {
//          self.repostURI = previousState
//      }
//  }
}

