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
    private var contexts: [String: PostContextModel] = [:]
    private var posts: [PostModel] = []
    @ObservationIgnored
    public var clientManager: ClientManager? = nil
}

// MARK: - POST MANAGER FUNCTIONS
extension PostManager {
    // MARK: - GET POST
    public func get(for post: PostModel, client: ClientManager) -> PostContextModel {
        if let context = contexts[post.uri] {
            return context
        } else {
            let context = PostContextModel(likeURI: post.likeURI, repostURI: post.repostURI, likeCount: post.likeCount, repostCount: post.repostCount)
            contexts[post.uri] = context
            return context
        }
    }
    
    // MARK: - GET FEED
    public func getFeed() async -> [PostModel] {
        guard let configuration = clientManager?.configuration else {
            print("🍄⛔️ ProfileManager: No configuration available")
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
    
    // MARK: - GET AUTHOR FEED
    public func getAuthorFeed(by did: String, shouldIncludePins: Bool) async -> [PostModel] {
        guard let configuration = clientManager?.configuration else {
            print("🍄⛔️ ProfileManager: No configuration available")
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
    
    // MARK:  - GET CONTEXT MANAGER
    public func contextManager(forURI uri: String, client: ClientManager) -> PostContextManager? {
        guard let post = posts.first(where: { $0.uri == uri }) else { return nil }
        let context = get(for: post, client: client)
        return PostContextManager(post: post, client: client, model: context)
    }
}

// MARK: - POST CONTEXT MANAGER
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
        let model: PostContextModel
        
        public init(post: PostModel, client: ClientManager, model: PostContextModel) {
            self.post = post
            self.client = client
            self.model = model
        }
        
        // MARK: - UPDATE CONTEXT
        public func update(with post: PostModel) {
            self.post = post
            model.likeURI = post.likeURI
            model.repostURI = post.repostURI
        }
        
        // MARK: - LIKE POST
        // MARK: - LIKE POST
        public func toggleLike() async {
            let previousLikeURI = model.likeURI
            let previousBaseLikeCount = model.baseLikeCount
            
            do {
                if model.likeURI != nil {
                    // Store the URI before setting it to nil
                    let uriToDelete = model.likeURI!
                    
                    // Optimistic update
                    model.likeURI = nil
                    model.baseLikeCount = max(0, model.baseLikeCount)
                    
                    // Make the network call
                    try await client.blueskyClient.deleteRecord(.recordURI(atURI: uriToDelete))
                } else {
                    // Optimistic update
                    model.likeURI = "ui.optimistic.like"
                    model.baseLikeCount = model.baseLikeCount
                    
                    // Make the network call
                    let likeRecord = try await client.blueskyClient.createLikeRecord(
                        .init(recordURI: post.uri, cidHash: post.cid)
                    )
                    model.likeURI = likeRecord.recordURI
                }
            } catch {
                // Revert all changes on error
                model.likeURI = previousLikeURI
                model.baseLikeCount = previousBaseLikeCount
                print("Error toggling like: \(error)")
            }
        }
        
        // MARK: - REPOST POST
        public func toggleRepost() async {
            let previousRepostURI = model.repostURI
            let previousBaseRepostCount = model.baseRepostCount
            
            do {
                if model.repostURI != nil {
                    // Store the URI before setting it to nil
                    let uriToDelete = model.repostURI!
                    
                    // Optimistic update
                    model.repostURI = nil
                    model.baseRepostCount = max(0, model.baseRepostCount)
                    
                    // Make the network call
                    try await client.blueskyClient.deleteRecord(.recordURI(atURI: uriToDelete))
                } else {
                    // Optimistic update
                    model.repostURI = "ui.optimistic.repost"
                    model.baseRepostCount = model.baseRepostCount
                    
                    // Make the network call
                    let repostRecord = try await client.blueskyClient.createRepostRecord(
                        .init(recordURI: post.uri, cidHash: post.cid)
                    )
                    model.repostURI = repostRecord.recordURI
                }
            } catch {
                // Revert all changes on error
                model.repostURI = previousRepostURI
                model.baseRepostCount = previousBaseRepostCount
                print("Error toggling repost: \(error)")
            }
        }
    }
}
