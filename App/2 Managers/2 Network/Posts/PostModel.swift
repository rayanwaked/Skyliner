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
    var isLiked: Bool
    var isReposted: Bool
    var likeCount: Int
    var repostCount: Int
    var replyCount: Int
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
    
    // MARK: - METHODS
    func updatePosts<T: PostViewProtocol>(_ newPosts: [T]) {
        rawPosts = newPosts
        posts = newPosts.map { createPostItem(from: $0) }
    }
    
    func appendPosts<T: PostViewProtocol>(_ newPosts: [T]) {
        let newItems = newPosts.map { createPostItem(from: $0) }
        rawPosts.append(contentsOf: newPosts)
        posts.append(contentsOf: newItems)
    }
    
    func appendPostsWithDuplicateCheck<T: PostViewProtocol>(_ newPosts: [T]) {
        let existingURIs = Set(rawPosts.map { $0.uri })
        let uniqueNewPosts = newPosts.filter { !existingURIs.contains($0.uri) }
        
        guard !uniqueNewPosts.isEmpty else { return }
        
        let newItems = uniqueNewPosts.map { createPostItem(from: $0) }
        rawPosts.append(contentsOf: uniqueNewPosts)
        posts.append(contentsOf: newItems)
    }
    
    func clear() {
        posts = []
        rawPosts = []
    }
    
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        rawPosts.first { $0.uri == postID }
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
            time: DateHelper.formattedRelativeDate(from: extractDate(from: post.record)),
            message: extractMessage(from: post.record),
            embed: post.embed,
            rawPost: post
        )
    }

    internal func performCreatePostItem(from post: any PostViewProtocol) -> PostItem {
        createPostItem(from: post)
    }
    
    private func extractMessage(from record: UnknownType) -> String {
        guard let postRecord = Mirror(reflecting: record).children
            .first(where: { $0.label == "record" })?
            .value as? AppBskyLexicon.Feed.PostRecord
        else { return "Unable to parse content" }
        
        return postRecord.text
    }
    
    private func extractDate(from record: UnknownType) -> Date {
        guard let postRecord = Mirror(reflecting: record).children
            .first(where: { $0.label == "record" })?
            .value as? AppBskyLexicon.Feed.PostRecord
        else { return Date() }
        
        return postRecord.createdAt
    }
}

