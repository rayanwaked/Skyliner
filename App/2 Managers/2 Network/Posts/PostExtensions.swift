//
//  PostReplyExtension.swift
//  Skyliner
//
//  Created by Rayan Waked on [Date]
//

import SwiftUI
import ATProtoKit
import SwiftyBeaver

// MARK: - REPLY EXTENSION
extension PostManager {
    // MARK: - CREATE REPLY (SIMPLE VERSION)
    public func createReply(to parentPost: PostItem, text: String) async throws {
        guard let clientManager else {
            throw PostReplyError.noClientManager
        }
        
        guard !text.isEmpty, text.count <= 300 else {
            throw PostReplyError.invalidReplyText
        }
        
        // Get the post thread to ensure we have proper references
        let threadResult = try await clientManager.account.getPostThread(
            from: parentPost.postID,
            depth: 1,
            parentHeight: 100
        )
        
        // Extract the parent and root references from the thread
        guard case .threadViewPost(let threadView) = threadResult.thread else {
            throw PostReplyError.invalidPostType
        }
        
        let parentRef = ComAtprotoLexicon.Repository.StrongReference(
            recordURI: threadView.post.uri,
            cidHash: threadView.post.cid
        )
        
        // Check if this post is already a reply to get the correct root
        let rootRef: ComAtprotoLexicon.Repository.StrongReference
        if let postRecord = threadView.post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self),
           let replyRef = postRecord.reply {
            // Use existing root if this is part of a thread
            rootRef = replyRef.root
        } else {
            // This is a top-level post, so it becomes the root
            rootRef = parentRef
        }
        
        // Create the reply reference
        let replyReference = AppBskyLexicon.Feed.PostRecord.ReplyReference(
            root: rootRef,
            parent: parentRef
        )
        
        // Post the reply
        _ = try await clientManager.bluesky.createPostRecord(
            text: text,
            replyTo: replyReference
        )
        
        log.verbose("Reply posted successfully")
    }
}

// MARK: - ERROR ENUM
@MainActor
enum PostReplyError: Error, @preconcurrency LocalizedError {
    case noClientManager
    case invalidReplyText
    case invalidPostType
    
    var errorDescription: String? {
        switch self {
        case .noClientManager:
            return "No client manager available"
        case .invalidReplyText:
            return "Reply text is empty or exceeds 300 characters"
        case .invalidPostType:
            return "Invalid post type for reply"
        }
    }
}

// MARK: - SEARCH MANAGER EXTENSION
extension SearchManager {
    public func createReply(to parentPost: PostItem, text: String) async throws {
        guard let clientManager else {
            throw PostReplyError.noClientManager
        }
        
        guard !text.isEmpty, text.count <= 300 else {
            throw PostReplyError.invalidReplyText
        }
        
        // Get the post thread
        let threadResult = try await clientManager.account.getPostThread(
            from: parentPost.postID,
            depth: 1,
            parentHeight: 100
        )
        
        // Extract references
        guard case .threadViewPost(let threadView) = threadResult.thread else {
            throw PostReplyError.invalidPostType
        }
        
        let parentRef = ComAtprotoLexicon.Repository.StrongReference(
            recordURI: threadView.post.uri,
            cidHash: threadView.post.cid
        )
        
        let rootRef: ComAtprotoLexicon.Repository.StrongReference
        if let postRecord = threadView.post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self),
           let replyRef = postRecord.reply {
            rootRef = replyRef.root
        } else {
            rootRef = parentRef
        }
        
        let replyReference = AppBskyLexicon.Feed.PostRecord.ReplyReference(
            root: rootRef,
            parent: parentRef
        )
        
        // Post the reply
        _ = try await clientManager.bluesky.createPostRecord(
            text: text,
            replyTo: replyReference
        )
    }
}

// MARK: - USER MANAGER EXTENSION
extension UserManager {
    public func createReply(to parentPost: PostItem, text: String) async throws {
        guard let clientManager else {
            throw PostReplyError.noClientManager
        }
        
        guard !text.isEmpty, text.count <= 300 else {
            throw PostReplyError.invalidReplyText
        }
        
        // Get the post thread
        let threadResult = try await clientManager.account.getPostThread(
            from: parentPost.postID,
            depth: 1,
            parentHeight: 100
        )
        
        // Extract references
        guard case .threadViewPost(let threadView) = threadResult.thread else {
            throw PostReplyError.invalidPostType
        }
        
        let parentRef = ComAtprotoLexicon.Repository.StrongReference(
            recordURI: threadView.post.uri,
            cidHash: threadView.post.cid
        )
        
        let rootRef: ComAtprotoLexicon.Repository.StrongReference
        if let postRecord = threadView.post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self),
           let replyRef = postRecord.reply {
            rootRef = replyRef.root
        } else {
            rootRef = parentRef
        }
        
        let replyReference = AppBskyLexicon.Feed.PostRecord.ReplyReference(
            root: rootRef,
            parent: parentRef
        )
        
        // Post the reply
        _ = try await clientManager.bluesky.createPostRecord(
            text: text,
            replyTo: replyReference
        )
    }
}

// MARK: - PROFILE MANAGER EXTENSION
extension ProfileManager {
    public func createReply(to parentPost: PostItem, text: String) async throws {
        guard let clientManager else {
            throw PostReplyError.noClientManager
        }
        
        guard !text.isEmpty, text.count <= 300 else {
            throw PostReplyError.invalidReplyText
        }
        
        // Get the post thread
        let threadResult = try await clientManager.account.getPostThread(
            from: parentPost.postID,
            depth: 1,
            parentHeight: 100
        )
        
        // Extract references
        guard case .threadViewPost(let threadView) = threadResult.thread else {
            throw PostReplyError.invalidPostType
        }
        
        let parentRef = ComAtprotoLexicon.Repository.StrongReference(
            recordURI: threadView.post.uri,
            cidHash: threadView.post.cid
        )
        
        let rootRef: ComAtprotoLexicon.Repository.StrongReference
        if let postRecord = threadView.post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self),
           let replyRef = postRecord.reply {
            rootRef = replyRef.root
        } else {
            rootRef = parentRef
        }
        
        let replyReference = AppBskyLexicon.Feed.PostRecord.ReplyReference(
            root: rootRef,
            parent: parentRef
        )
        
        // Post the reply
        _ = try await clientManager.bluesky.createPostRecord(
            text: text,
            replyTo: replyReference
        )
    }
}

