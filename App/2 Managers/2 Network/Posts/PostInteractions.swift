//
//  PostInteractions.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/18/25.
//

import SwiftUI
import ATProtoKit

// MARK: - PROTOCOL
protocol PostInteractionCapable: AnyObject {
    var clientManager: ClientManager? { get }
}

enum PostAction {
    case like, repost
}

// MARK: - LOGIC
extension PostInteractionCapable {
    // MARK: - METHODS
    func toggleInteraction(_ action: PostAction, uri: String, cid: String?, existingURI: String?) async {
        switch (action, existingURI) {
        case (.like, let likeURI?) :
            await run("Unliking post") {
                try await clientManager?.bluesky.deleteRecord(.recordURI(atURI: likeURI))
            }
        case (.like, nil):
            await run("Liking post") {
                _ = try await clientManager?.bluesky.createLikeRecord(.init(recordURI: uri, cidHash: cid!))
            }
        case (.repost, let repostURI?) :
            await run("Unreposting") {
                try await clientManager?.bluesky.deleteRecord(.recordURI(atURI: repostURI))
            }
        case (.repost, nil):
            await run("Reposting") {
                _ = try await clientManager?.bluesky.createRepostRecord(.init(recordURI: uri, cidHash: cid!))
            }
        }
    }
    
    func sharePost(authorName: String?, handle: String, content: String) {
        present(["\(authorName ?? handle): \(content)\n\nVia Skyliner for Bluesky"])
    }
    
    func copyPostLink(uri: String) {
        UIPasteboard.general.string = "https://bsky.app/profile/\(uri)"
    }
    
    func openExternalLink(_ urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        _ = await UIApplication.shared.open(url)
    }
    
    func extractDomain(from urlString: String) -> String {
        URL(string: urlString)?
            .host?
            .replacingOccurrences(of: "^www\\.", with: "", options: .regularExpression)
        ?? urlString
    }
    
    // MARK: - HELPERS
    private func run(_ title: String, _ operation: () async throws -> Void) async {
        do {
            try await operation()
            print("✅ \(title) completed successfully")
        } catch {
            print("❌ Failed to \(title.lowercased()): \(error.localizedDescription)")
        }
    }
    
    func extractMessage(from record: UnknownType) -> String {
        guard let postRecord = Mirror(reflecting: record).children
            .first(where: { $0.label == "record" })?
            .value as? AppBskyLexicon.Feed.PostRecord else {
            return "Unable to parse content"
        }
        return postRecord.text
    }
    
    func present(_ items: [Any]) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first?.windows.first
        else { return }
        
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = window
        vc.popoverPresentationController?.sourceRect = CGRect(
            x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0
        )
        window.rootViewController?.present(vc, animated: true)
    }
}

// MARK: - FINDER PROTOCOL
protocol PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)?
}

// MARK: - INTERACTIONS
extension PostInteractionCapable where Self: PostFinder {
    func getPostState(postID: String) -> (isLiked: Bool, isReposted: Bool, likeCount: Int, repostCount: Int, replyCount: Int) {
        guard let post = findPost(by: postID) else { return (false, false, 0, 0, 0) }
        return (
            isLiked: post.viewer?.likeURI != nil,
            isReposted: post.viewer?.repostURI != nil,
            likeCount: post.likeCount ?? 0,
            repostCount: post.repostCount ?? 0,
            replyCount: post.replyCount ?? 0
        )
    }
    
    func toggleLike(postID: String) async {
        guard let post = findPost(by: postID) else {
            print("❌ Post not found for toggle like")
            return
        }
        await toggleInteraction(.like, uri: post.uri, cid: post.cid, existingURI: post.viewer?.likeURI)
    }
    
    func toggleRepost(postID: String) async {
        guard let post = findPost(by: postID) else {
            print("❌ Post not found for toggle repost")
            return
        }
        await toggleInteraction(.repost, uri: post.uri, cid: post.cid, existingURI: post.viewer?.repostURI)
    }
    
    func sharePost(postID: String) {
        guard let post = findPost(by: postID) else {
            print("❌ Post not found for sharing")
            return
        }
        sharePost(authorName: post.author.displayName, handle: post.author.actorHandle, content: extractMessage(from: post.record))
    }
    
    func copyPostLink(postID: String) {
        guard let post = findPost(by: postID) else {
            print("❌ Post not found for copying link")
            return
        }
        copyPostLink(uri: post.uri)
    }
}

// MARK: - POST MANAGER EXTENSION
extension PostManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        homeFeed.findPost(by: postID) ?? authorFeed.findPost(by: postID)
    }
}

// MARK: - SEARCH MANAGER EXTENSION
extension SearchManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        searchFeed.findPost(by: postID)
    }
}
