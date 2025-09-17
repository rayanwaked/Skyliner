//
//  PostAction.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/23/25.
//

import SwiftUI

// MARK: - ACTIONS
extension PostCell {
    var actions: some View {
        HStack {
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
                HStack {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                    Text("\(repostCount)")
                        .contentTransition(.numericText())
                }
                .foregroundStyle(isReposted ? .blue : .primary.opacity(Opacity.heavy))
            }
            
            Spacer()
            
            // MARK: - REPLY
            Button {
                routerCoordinator.showReply(for: post)
                hapticFeedback(.soft)
            } label: {
                HStack {
                    Image(systemName: "message")
                    Text("\(replyCount)")
                }
                .foregroundStyle(.foreground.opacity(Opacity.heavy))
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
                HStack {
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
        .padding(.top, Padding.small)
        .padding(.trailing, Padding.tiny)
        .sheet(isPresented: .constant(routerCoordinator.showingReport)) {
            // TODO: Implement ReportView here (e.g., ReportView(postID: post.postID, authorDID: post.authorDID, manager: manager))
        }
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

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ScrollView {
        PostFeature(location: .home)
            .environment(appState)
    }
}

