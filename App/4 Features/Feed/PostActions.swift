//
//  PostActions.swift
//  Skyliner
//

import SwiftUI

// MARK: - POST ACTIONS VIEW
struct PostActions: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    private var postManager: PostManager? { appState.postManager }
    
    let postID: String
    
    @State private var postState = PostState(
        isLiked: false,
        isReposted: false,
        likeCount: 0,
        repostCount: 0,
        replyCount: 0
    )
    
    // MARK: - BODY
    var body: some View {
        HStack {
            // REPOST
            Button {
                Task {
                    await handleRepostAction()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                    Text("\(postState.repostCount)")
                        .contentTransition(.numericText())
                }
                .foregroundStyle(postState.isReposted ? .blue : .primary.opacity(0.7))
            }
            
            Spacer()
            
            // REPLY
            Button {
                handleReplyAction()
            } label: {
                HStack {
                    Image(systemName: "message")
                    Text("\(postState.replyCount)")
                }
                .foregroundStyle(.foreground.opacity(0.7))
            }
            
            Spacer()
            
            // LIKE
            Button {
                Task {
                    await handleLikeAction()
                }
            } label: {
                HStack {
                    Image(systemName: postState.isLiked ? "heart.fill" : "heart")
                    Text("\(postState.likeCount)")
                        .contentTransition(.numericText())
                }
                .foregroundStyle(postState.isLiked ? .red : .primary.opacity(0.7))
            }
            
            Spacer()
            
            // SHARE
            Button {
                handleShareAction()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.foreground.opacity(0.7))
            }
            
            Spacer()
            
            // MENU
            Menu {
                Button("Copy Link") {
                    handleCopyLinkAction()
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.foreground.opacity(0.7))
            }
        }
        .font(.subheadline)
        .padding(.top, Padding.small)
        .padding(.leading, Padding.tiny)
        .padding(.trailing, Padding.standard)
        .task {
            refreshPostState()
        }
    }
    
    // MARK: - ACTIONS
    private func handleLikeAction() async {
        // Optimistic UI update
        withAnimation(.bouncy()) {
            postState.isLiked.toggle()
            postState.likeCount += postState.isLiked ? 1 : -1
        }
        
        // Delegate to manager
        await postManager?.toggleLike(postID: postID)
        refreshPostState()
    }
    
    private func handleRepostAction() async {
        // Optimistic UI update
        withAnimation(.bouncy()) {
            postState.isReposted.toggle()
            postState.repostCount += postState.isReposted ? 1 : -1
        }
        
        // Delegate to manager
        await postManager?.toggleRepost(postID: postID)
        refreshPostState()
    }
    
    private func handleReplyAction() {
        // Handle reply action - implement based on your reply flow
        // This should probably navigate to a reply composer
    }
    
    private func handleShareAction() {
        postManager?.sharePost(postID: postID)
    }
    
    private func handleCopyLinkAction() {
        postManager?.copyPostLink(postID: postID)
    }
    
    private func refreshPostState() {
        if let manager = postManager {
            postState = manager.getPostState(postID: postID)
        }
    }
}

// MARK: - CONVENIENCE BUILDER
func postInteractions(postID: String) -> some View {
    PostActions(postID: postID)
}
