//
//  ThreadManager+PostManaging.swift
//  Skyliner
//
//  Created by Rayan Waked on [Date]
//

import SwiftUI
import ATProtoKit

// MARK: - THREAD MANAGER CONFORMANCE
extension ThreadManager: PostManaging {
    var displayPosts: [PostItem] {
        threads.map { $0.post }
    }
    
    func getPostState(postID: String) -> PostState {
        // First check parent post
        if parentPost?.postID == postID {
            guard let rawPost = parentPost?.rawPost else {
                return PostState(isLiked: false, isReposted: false, likeCount: 0, repostCount: 0, replyCount: 0)
            }
            return PostState(
                isLiked: rawPost.viewer?.likeURI != nil,
                isReposted: rawPost.viewer?.repostURI != nil,
                likeCount: rawPost.likeCount ?? 0,
                repostCount: rawPost.repostCount ?? 0,
                replyCount: rawPost.replyCount ?? 0
            )
        }
        
        // Then check thread items
        guard let threadItem = threads.first(where: { $0.post.postID == postID }) else {
            return PostState(isLiked: false, isReposted: false, likeCount: 0, repostCount: 0, replyCount: 0)
        }
        
        let rawPost = threadItem.post.rawPost
        return PostState(
            isLiked: rawPost.viewer?.likeURI != nil,
            isReposted: rawPost.viewer?.repostURI != nil,
            likeCount: rawPost.likeCount ?? 0,
            repostCount: rawPost.repostCount ?? 0,
            replyCount: rawPost.replyCount ?? 0
        )
    }
    
    func toggleLike(postID: String) async {
        guard let post = findPost(by: postID) else {
            print("⚠️ Post not found for toggle like")
            return
        }
        await toggleInteraction(.like, uri: post.uri, cid: post.cid, existingURI: post.viewer?.likeURI)
    }
    
    func toggleRepost(postID: String) async {
        guard let post = findPost(by: postID) else {
            print("⚠️ Post not found for toggle repost")
            return
        }
        await toggleInteraction(.repost, uri: post.uri, cid: post.cid, existingURI: post.viewer?.repostURI)
    }
    
    func sharePost(postID: String) {
        guard let post = findPost(by: postID) else {
            print("⚠️ Post not found for sharing")
            return
        }
        sharePost(
            authorName: post.author.displayName,
            handle: post.author.actorHandle,
            content: extractMessage(from: post.record)
        )
    }
    
    func copyPostLink(postID: String) {
        guard let post = findPost(by: postID) else {
            print("⚠️ Post not found for copying link")
            return
        }
        copyPostLink(uri: post.uri)
    }
    
    func createReply(to parentPost: PostItem, text: String) async throws {
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
        
        print("✅ Reply posted successfully")
    }
    
    // MARK: - MODERATION METHODS
    func reportPost(postID: String, reason: ReportReason, additionalContext: String?) async throws {
        guard let clientManager else {
            throw ModerationError.noClientManager
        }
        
        guard let post = findPost(by: postID) else {
            throw ModerationError.postNotFound
        }
        
        let subject = ComAtprotoLexicon.Moderation.CreateReportRequestBody.SubjectUnion.strongReference(
            .init(recordURI: post.uri, cidHash: post.cid)
        )
        
        _ = try await clientManager.account.createReport(
            with: reason.moderationReason,
            andContextof: additionalContext,
            subject: subject
        )
        
        print("✅ Post reported successfully")
    }
    
    func blockUser(authorDID: String) async throws {
        guard let clientManager else {
            throw ModerationError.noClientManager
        }
        
        _ = try await clientManager.bluesky.createBlockRecord(ofType: .actorBlock(actorDID: authorDID))
        print("✅ User blocked successfully")
    }
    
    func blockUserFromPost(postID: String) async throws {
        guard let post = findPost(by: postID) else {
            throw ModerationError.postNotFound
        }
        
        try await blockUser(authorDID: post.author.actorDID)
    }
}
