//
//  ThreadManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/31/25.
//

import SwiftUI
import ATProtoKit

// MARK: - THREAD ITEM
public struct ThreadItem {
    let post: PostItem
    let depth: Int
    let hasMoreReplies: Bool
    let parentAuthor: String?
}

// MARK: - THREAD MODEL
@MainActor
@Observable
public final class ThreadModel {
    // MARK: - PROPERTIES
    private(set) var threads: [ThreadItem] = []
    private(set) var parentPost: PostItem?
    private let postModel = PostModel()
    
    // MARK: - METHODS
    func updateThread(from threadView: AppBskyLexicon.Feed.ThreadViewPostDefinition) {
        clear()
        
        // Process parent posts if available
        if let parentThread = threadView.parent {
            switch parentThread {
            case .threadViewPost(let parentPost):
                // Process parent recursively
                processParentThread(parentPost)
            case .notFoundPost, .blockedPost:
                break
            case .unknown(_, _):
                break
            }
        }
        
        // Process main post
        parentPost = postModel.performCreatePostItem(from: threadView.post)
        
        // Process thread hierarchy
        processThreadNode(threadView, depth: 0)
    }
    
    func clear() {
        threads = []
        parentPost = nil
    }
    
    // MARK: - PRIVATE HELPERS
    private func processParentThread(_ parentThread: AppBskyLexicon.Feed.ThreadViewPostDefinition) {
        // Recursively process parents
        if let grandParent = parentThread.parent {
            switch grandParent {
            case .threadViewPost(let grandParentPost):
                processParentThread(grandParentPost)
            case .notFoundPost, .blockedPost:
                break
            case .unknown(_, _):
                break
            }
        }
        
        // Add parent to threads
        let item = postModel.performCreatePostItem(from: parentThread.post)
        let threadItem = ThreadItem(
            post: item,
            depth: -1, // Negative depth for parents
            hasMoreReplies: false,
            parentAuthor: nil
        )
        threads.append(threadItem)
    }
    
    private func processThreadNode(_ node: AppBskyLexicon.Feed.ThreadViewPostDefinition, depth: Int, parentAuthor: String? = nil) {
        // Add current post
        let item = postModel.performCreatePostItem(from: node.post)
        let threadItem = ThreadItem(
            post: item,
            depth: depth,
            hasMoreReplies: (node.replies?.count ?? 0) > 0,
            parentAuthor: parentAuthor
        )
        threads.append(threadItem)
        
        // Process replies recursively
        if let replies = node.replies {
            for reply in replies {
                switch reply {
                case .threadViewPost(let threadPost):
                    processThreadNode(
                        threadPost,
                        depth: depth + 1,
                        parentAuthor: node.post.author.displayName ?? node.post.author.actorHandle
                    )
                case .notFoundPost, .blockedPost:
                    // Skip blocked or not found posts
                    continue
                case .unknown(_, _):
                    break
                }
            }
        }
    }
}

// MARK: - THREAD MANAGER
@MainActor
@Observable
public final class ThreadManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    
    public let threadModel = ThreadModel()
    
    // MARK: - COMPUTED PROPERTIES
    var threads: [ThreadItem] { threadModel.threads }
    var parentPost: PostItem? { threadModel.parentPost }
    var hasThreadData: Bool { !threads.isEmpty || parentPost != nil }
    
    // MARK: - METHODS
    func loadThread(uri: String, depth: Int? = nil, parentHeight: Int? = nil) async {
        guard let clientManager else {
            print("❌ No valid client manager available for thread loading")
            return
        }
        
        await execute("Loading thread") {
            // Following the pattern from getAuthorFeed in PostManager
            let threadResult = try await clientManager.account.getPostThread(
                from: uri,
                depth: depth,
                parentHeight: parentHeight
            )
            
            // Process based on thread type
            switch threadResult.thread {
            case .threadViewPost(let threadView):
                self.threadModel.updateThread(from: threadView)
            case .notFoundPost:
                print("❌ Thread post not found")
                self.threadModel.clear()
            case .blockedPost:
                print("❌ Thread post is blocked")
                self.threadModel.clear()
            case .unknown(_, _):
                break
            }
        }
    }
    
    func refreshThread(uri: String, depth: Int? = nil, parentHeight: Int? = nil) async {
        threadModel.clear()
        await loadThread(uri: uri, depth: depth, parentHeight: parentHeight)
    }
    
    // MARK: - HELPERS
    private func execute(_ operationName: String, operation: () async throws -> Void) async {
        do {
            try await operation()
            print("✅ \(operationName) completed successfully")
        } catch {
            print("❌ Failed to \(operationName.lowercased()): \(error.localizedDescription)")
        }
    }
}

// MARK: - THREAD INTERACTIONS
extension ThreadManager: PostInteractionCapable, PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)? {
        // First check parent post
        if parentPost?.postID == postID {
            return parentPost?.rawPost
        }
        
        // Then check thread items
        return threads.first(where: { $0.post.postID == postID })?.post.rawPost
    }
}
