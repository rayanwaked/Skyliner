//
//  PostModel.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/23/25.
//

import SwiftUI
import ATProtoKit

// MARK: - ITEM MODEL
public struct PostItem {
    let postID: String
    let imageURL: URL?
    let name: String
    let handle: String
    let message: String
    let embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?
    let rawPost: any PostViewProtocol
}

// MARK: - VIEW PROTOCOL
protocol PostViewProtocol {
    var uri: String { get }
    var cid: String { get }
    var author: AppBskyLexicon.Actor.ProfileViewBasicDefinition { get }
    var record: UnknownType { get }
    var embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion? { get }
    var viewer: AppBskyLexicon.Feed.ViewerStateDefinition? { get }
    var likeCount: Int? { get }
    var repostCount: Int? { get }
    var replyCount: Int? { get }
}

// MARK: - PROTOCOL CONFORMANCE
extension AppBskyLexicon.Feed.PostViewDefinition: PostViewProtocol { }

extension AppBskyLexicon.Feed.FeedViewPostDefinition: PostViewProtocol {
    var uri: String { post.uri }
    var cid: String { post.cid }
    var author: AppBskyLexicon.Actor.ProfileViewBasicDefinition { post.author }
    var record: UnknownType { post.record }
    var embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion? { post.embed }
    var viewer: AppBskyLexicon.Feed.ViewerStateDefinition? { post.viewer }
    var likeCount: Int? { post.likeCount }
    var repostCount: Int? { post.repostCount }
    var replyCount: Int? { post.replyCount }
}

// MARK: - POST MODEL
@MainActor
@Observable
public final class PostModel {
    // MARK: - PROPERTIES
    private(set) var posts: [PostItem] = []
    private var rawPosts: [any PostViewProtocol] = []
    
    // MARK: - COMPUTED PROPERTIES
    var postData: [(postID: String, imageURL: URL?, name: String, handle: String, message: String, embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?)] {
        posts.map { ($0.postID, $0.imageURL, $0.name, $0.handle, $0.message, $0.embed) }
    }
    
    // MARK: - METHODS
    func updatePosts<T: PostViewProtocol>(_ newPosts: [T]) {
        rawPosts = newPosts
        posts = newPosts.map { post in
            PostItem(
                postID: post.uri,
                imageURL: post.author.avatarImageURL,
                name: post.author.displayName ?? post.author.actorHandle,
                handle: post.author.actorHandle,
                message: extractMessage(from: post.record),
                embed: post.embed,
                rawPost: post
            )
        }
    }
    
    func appendPosts<T: PostViewProtocol>(_ newPosts: [T]) {
        let newItems = newPosts.map { post in
            PostItem(
                postID: post.uri,
                imageURL: post.author.avatarImageURL,
                name: post.author.displayName ?? post.author.actorHandle,
                handle: post.author.actorHandle,
                message: extractMessage(from: post.record),
                embed: post.embed,
                rawPost: post
            )
        }
        rawPosts.append(contentsOf: newPosts)
        posts.append(contentsOf: newItems)
    }
    
    func clear() {
        posts = []
        rawPosts = []
    }
    
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        rawPosts.first { $0.uri == postID }
    }
    
    func getPostState(postID: String) -> (isLiked: Bool, isReposted: Bool, likeCount: Int, repostCount: Int, replyCount: Int) {
        guard let post = findPost(by: postID) else {
            return (false, false, 0, 0, 0)
        }
        
        return (
            isLiked: post.viewer?.likeURI != nil,
            isReposted: post.viewer?.repostURI != nil,
            likeCount: post.likeCount ?? 0,
            repostCount: post.repostCount ?? 0,
            replyCount: post.replyCount ?? 0
        )
    }
    
    // MARK: - HELPER METHODS
    private func extractMessage(from record: UnknownType) -> String {
        let mirror = Mirror(reflecting: record)
        
        if let recordChild = mirror.children.first(where: { $0.label == "record" }),
           let postRecord = recordChild.value as? AppBskyLexicon.Feed.PostRecord {
            return postRecord.text
        }
        
        return "Unable to parse content"
    }
}
