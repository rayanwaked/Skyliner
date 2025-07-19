//
//  PostInteractions.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/18/25.
//

import SwiftUI
import ATProtoKit

// MARK: - EXTENSION
extension PostManager {
    // MARK: - HELPER - FIND POST BY ID
    private func findPost(by postID: String) -> AppBskyLexicon.Feed.FeedViewPostDefinition? {
        return homeFeed.flatMap(\.feed).first { $0.post.uri == postID }
    }
    
    // MARK: - LIKE
    public func likePost(postID: String) async {
        guard let post = findPost(by: postID) else {
            logError("Post not found for liking")
            return
        }
        
        await execute("Liking post") {
            let strongRef = ComAtprotoLexicon.Repository.StrongReference(recordURI: post.post.uri, cidHash: post.post.cid)
            _ = try await clientManager?.bluesky.createLikeRecord(strongRef)
        }
    }
    
    // MARK: - UNLIKE
    public func unlikePost(postID: String) async {
        guard let post = findPost(by: postID),
              let likeURI = post.post.viewer?.likeURI else {
            logError("No like URI available for unlike")
            return
        }
        
        await execute("Unliking post") {
            _ = try await clientManager?.bluesky
                .deleteRecord(.recordURI(atURI: likeURI))
        }
    }
    
    // MARK: - REPOST
    public func repost(postID: String) async {
        guard let post = findPost(by: postID) else {
            logError("Post not found for reposting")
            return
        }
        
        await execute("Reposting") {
            let strongRef = ComAtprotoLexicon.Repository.StrongReference(recordURI: post.post.uri, cidHash: post.post.cid)
            _ = try await clientManager?.bluesky.createRepostRecord(strongRef)
        }
    }
    
    // MARK: - UNREPOST
    public func unrepost(postID: String) async {
        guard let post = findPost(by: postID),
              let repostURI = post.post.viewer?.repostURI else {
            logError("No repost URI available for unrepost")
            return
        }
        
        await execute("Unreposting") {
            _ = try await clientManager?.bluesky.deleteRecord(.recordURI(atURI: repostURI))
        }
    }
    
    // MARK: - TOGGLE LIKE
    public func toggleLike(postID: String) async {
        guard let post = findPost(by: postID) else {
            logError("Post not found for toggle like")
            return
        }
        
        if post.post.viewer?.likeURI != nil {
            await unlikePost(postID: postID)
        } else {
            await likePost(postID: postID)
        }
    }
    
    // MARK: - TOGGLE REPOST
    public func toggleRepost(postID: String) async {
        guard let post = findPost(by: postID) else {
            logError("Post not found for toggle repost")
            return
        }
        
        if post.post.viewer?.repostURI != nil {
            await unrepost(postID: postID)
        } else {
            await repost(postID: postID)
        }
    }
    
    // MARK: - SHARE
    public func sharePost(postID: String) {
        guard let post = findPost(by: postID) else {
            logError("Post not found for sharing")
            return
        }
        
        let content = extractMessage(from: post.post.record)
        let shareText = "\(post.post.author.displayName ?? post.post.author.actorHandle): \(content)\n\nVia Skyliner for Bluesky"
        present([shareText])
    }
    
    // MARK: - COPY LINK
    public func copyPostLink(postID: String) {
        guard let post = findPost(by: postID) else {
            logError("Post not found for copying link")
            return
        }
        
        UIPasteboard.general.string = "https://bsky.app/profile/\(post.post.uri)"
    }
    
    // MARK: - GET POST STATE
    public func getPostState(postID: String) -> (isLiked: Bool, isReposted: Bool, likeCount: Int, repostCount: Int) {
        guard let post = findPost(by: postID) else {
            return (false, false, 0, 0)
        }
        
        return (
            isLiked: post.post.viewer?.likeURI != nil,
            isReposted: post.post.viewer?.repostURI != nil,
            likeCount: post.post.likeCount ?? 0,
            repostCount: post.post.repostCount ?? 0
        )
    }
    
    // MARK: - OPEN EXTERNAL LINK
    public func openExternalLink(_ urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        _ = await UIApplication.shared.open(url)
    }
    
    // MARK: - EXTRACT DOMAIN
    public func extractDomain(from urlString: String) -> String {
        URL(string: urlString)?.host?.replacingOccurrences(of: "^www\\.", with: "", options: .regularExpression) ?? urlString
    }
}
