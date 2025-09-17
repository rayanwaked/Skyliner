//
//  ThreadAction.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/15/25.
//

import SwiftUI

// MARK: - POST ACTION BAR
struct ThreadActionBar: View {
    @Environment(AppState.self) var appState
    @Environment(RouterCoordinator.self) var routerCoordinator
    
    let post: PostItem
    let manager: PostManaging
    
    @Binding var isLiked: Bool
    @Binding var isReposted: Bool
    @Binding var likeCount: Int
    @Binding var repostCount: Int
    @Binding var replyCount: Int
    
    var body: some View {
        HStack {
            // MARK: - REPLY
            Button {
                // TODO: Implement reply
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "message")
                    Text("\(replyCount)")
                        .contentTransition(.numericText())
                }
                .foregroundStyle(.foreground.opacity(Opacity.heavy))
            }
            
            Spacer()
            
            // MARK: - REPOST
            Button {
                Task {
                    isReposted.toggle()
                    withAnimation(.bouncy()) {
                        repostCount += isReposted ? 1 : -1
                    }
                    await manager.toggleRepost(postID: post.postID)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                    Text("\(repostCount)")
                        .contentTransition(.numericText())
                }
                .foregroundStyle(isReposted ? .blue : .primary.opacity(Opacity.heavy))
            }
            
            Spacer()
            
            // MARK: - LIKE
            Button {
                Task {
                    isLiked.toggle()
                    withAnimation(.bouncy()) {
                        likeCount += isLiked ? 1 : -1
                    }
                    await manager.toggleLike(postID: post.postID)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                    Text("\(likeCount)")
                        .contentTransition(.numericText())
                }
                .foregroundStyle(isLiked ? .red : .primary.opacity(Opacity.heavy))
            }
            
            Spacer()
            
            // MARK: - SHARE
            Button {
                manager.sharePost(postID: post.postID)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.foreground.opacity(Opacity.heavy))
            }
            
            Spacer()
            
            // MARK: - MENU
            Menu {
                Button("Copy Link", systemImage: "document.on.document") {
                    manager.copyPostLink(postID: post.postID)
                }
                
                Button("Report Post", systemImage: "flag") {
                    routerCoordinator.showingReport = true
                    routerCoordinator.reportID = post.postID
                    routerCoordinator.reportDID = post.authorDID
                }
                .foregroundStyle(.red)
                
                Button("Block User", systemImage: "person.slash") {
                    Task {
                        try await blockUser()
                    }
                }
                .foregroundStyle(.red)
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.foreground.opacity(Opacity.heavy))
            }
        }
        .font(.smaller(.subheadline))
    }
    
    // MARK: - HELPER METHODS
    private func blockUser() async throws {
        // You'll need to cast manager to access moderation methods
        if let postManager = manager as? PostManager {
            try await postManager.blockUserFromPost(postID: post.postID)
        } else if let searchManager = manager as? SearchManager {
            try await searchManager.blockUserFromPost(postID: post.postID)
        } else if let userManager = manager as? UserManager {
            try await userManager.blockUser(authorDID: post.authorDID)
        }
        
        hapticFeedback(.success)
    }
}
