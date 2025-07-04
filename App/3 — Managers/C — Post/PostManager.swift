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
            let context = PostContextModel(likeURI: post.likeURI, repostURI: post.repostURI, likeCount: post.likeCount, repostCount: post.repostCount)
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
        let manager = await ClientManager(configuration: configuration)
        guard let timeline = try? await client.getTimeline() else {
            print("Error fetching feed: could not get timeline")
            return []
        }
        posts = timeline.feed.compactMap { $0.postModel }
        clientManager = manager
        return posts
      }
    
    public func getAuthorFeed(by did: String, shouldIncludePins: Bool) async -> [PostModel] {
        guard let configuration = configuration else {
            print("PostManager.getFeed() returning early: configuration is nil")
            return []
        }
        let client = await ATProtoKit(sessionConfiguration: configuration)
        let manager = await ClientManager(configuration: configuration)

        do {
            let profileFeed = try await client.getAuthorFeed(
                by: did,
                limit: nil,
                cursor: nil,
                postFilter: nil,
                shouldIncludePins: shouldIncludePins
            )
            let posts = profileFeed.feed.compactMap { $0.postModel }
            self.posts = posts
            self.clientManager = manager
            return posts
        } catch {
            print("Error fetching author feed: \(error)")
            return []
        }
    }
  
    public func contextManager(forURI uri: String, client: ClientManager) -> PostContextManager? {
        guard let post = posts.first(where: { $0.uri == uri }) else { return nil }
        let context = get(for: post, client: client)
        return PostContextManager(post: post, client: client, model: context)
    }
}

extension PostManager {
    @MainActor
    @Observable
    public final class PostContextManager: Sendable {
        /// The post associated with this context manager.
        /// This should be a shared reference obtained from PostManager's posts.
        private var post: PostModel
        /// The client used for network actions.
        private let client: ClientManager
        /// The shared PostContextModel instance for this post.
        /// This should be obtained via PostManager and is intended to be a shared reference.
        private let model: PostContextModel

        public init(post: PostModel, client: ClientManager, model: PostContextModel) {
            self.post = post
            self.client = client
            self.model = model
        }

        public func update(with post: PostModel) {
            self.post = post
            model.likeURI = post.likeURI
            model.repostURI = post.repostURI
        }

        public func toggleLike() async {
            let previousState = model.likeURI
            do {
                if model.likeURI != nil {
                    self.model.likeURI = nil
                    try await client.blueskyClient.deleteRecord(.recordURI(atURI: model.likeURI ?? ""))
                } else {
                    model.likeURI = "ui.optimistic.like"
                    model.likeURI = try await client.blueskyClient.createLikeRecord(
                        .init(recordURI: post.uri, cidHash: post.cid)
                    ).recordURI
                }
            } catch {
                model.likeURI = previousState
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
}
