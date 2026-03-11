//
//  PostModel.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/23/25.
//

import SwiftUI
import ATProtoKit

// MARK: - POST ITEM
public struct PostItem {
    let authorDID: String
    let postID: String
    let imageURL: URL?
    let name: String
    let handle: String
    let time: String
    let message: String
    let embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?
    let rawPost: any PostViewProtocol
}

// MARK: - POST STATE
public struct PostState {
    let isLiked: Bool
    let isReposted: Bool
    let likeCount: Int
    let repostCount: Int
    let replyCount: Int
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
    // MARK: - CONSTANTS
    private static let maxPostsInMemory = 500
    
    // MARK: - PROPERTIES
    private(set) var posts: [PostItem] = []
    private var rawPosts: [any PostViewProtocol] = []
    // Cached set for O(1) duplicate lookups
    private var postURISet: Set<String> = []
    // Cached dictionary for O(1) post lookups by ID
    private var postsByURI: [String: any PostViewProtocol] = [:]
    
    // MARK: - METHODS
    func updatePosts<T: PostViewProtocol>(_ newPosts: [T]) {
        rawPosts = newPosts
        posts = newPosts.map { createPostItem(from: $0) }
        rebuildCaches()
    }
    
    func appendPosts<T: PostViewProtocol>(_ newPosts: [T]) {
        let newItems = newPosts.map { createPostItem(from: $0) }
        rawPosts.append(contentsOf: newPosts)
        posts.append(contentsOf: newItems)
        
        // Update caches incrementally
        for post in newPosts {
            postURISet.insert(post.uri)
            postsByURI[post.uri] = post
        }
        
        trimIfNeeded()
    }
    
    func appendPostsWithDuplicateCheck<T: PostViewProtocol>(_ newPosts: [T]) {
        // O(1) lookup using cached set instead of O(n) iteration
        let uniqueNewPosts = newPosts.filter { !postURISet.contains($0.uri) }
        
        guard !uniqueNewPosts.isEmpty else { return }
        
        let newItems = uniqueNewPosts.map { createPostItem(from: $0) }
        rawPosts.append(contentsOf: uniqueNewPosts)
        posts.append(contentsOf: newItems)
        
        // Update caches incrementally
        for post in uniqueNewPosts {
            postURISet.insert(post.uri)
            postsByURI[post.uri] = post
        }
        
        trimIfNeeded()
    }
    
    func clear() {
        posts = []
        rawPosts = []
        postURISet = []
        postsByURI = [:]
    }
    
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        // O(1) lookup using dictionary instead of O(n) iteration
        postsByURI[postID]
    }
    
    // MARK: - PRIVATE HELPERS
    private func rebuildCaches() {
        postURISet = Set(rawPosts.map { $0.uri })
        // Use reduce to handle potential duplicates (keep last occurrence)
        postsByURI = rawPosts.reduce(into: [:]) { dict, post in
            dict[post.uri] = post
        }
    }
    
    private func trimIfNeeded() {
        // Prevent unbounded memory growth by keeping only recent posts
        guard posts.count > Self.maxPostsInMemory else { return }
        
        let excess = posts.count - Self.maxPostsInMemory
        posts.removeFirst(excess)
        rawPosts.removeFirst(excess)
        rebuildCaches()
    }
    
    func getPostState(postID: String) -> PostState {
        guard let post = findPost(by: postID) else {
            return PostState(isLiked: false, isReposted: false, likeCount: 0, repostCount: 0, replyCount: 0)
        }
        
        return PostState(
            isLiked: post.viewer?.likeURI != nil,
            isReposted: post.viewer?.repostURI != nil,
            likeCount: post.likeCount ?? 0,
            repostCount: post.repostCount ?? 0,
            replyCount: post.replyCount ?? 0
        )
    }
    
    // MARK: - PRIVATE HELPERS
    private func createPostItem(from post: any PostViewProtocol) -> PostItem {
        PostItem(
            authorDID: post.author.actorDID,
            postID: post.uri,
            imageURL: post.author.avatarImageURL,
            name: post.author.displayName ?? post.author.actorHandle,
            handle: post.author.actorHandle,
            time: DateHelper.formattedRelativeDate(from: PostRecordParser.extractDate(from: post.record)),
            message: PostRecordParser.extractText(from: post.record),
            embed: post.embed,
            rawPost: post
        )
    }

    internal func performCreatePostItem(from post: any PostViewProtocol) -> PostItem {
        createPostItem(from: post)
    }
}

