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
                    // Optimistic update
                    isReposted.toggle()
                    withAnimation(.bouncy()) {
                        repostCount += isReposted ? 1 : -1
                    }
                    
                    // Call appropriate manager method
                    switch location {
                    case .home, .user:
                        await appState.postManager.toggleRepost(postID: postID)
                    case .explore:
                        await appState.searchManager.toggleRepost(postID: postID)
                    case .profile:
                        await appState.profileManager.toggleRepost(postID: postID)
                    }
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
                Task {
                    // TODO: Implement reply functionality
                }
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
                    // Optimistic update
                    isLiked.toggle()
                    withAnimation(.bouncy()) {
                        likeCount += isLiked ? 1 : -1
                    }
                    
                    switch location {
                    case .home, .user:
                        await appState.postManager.toggleLike(postID: postID)
                    case .explore:
                        await appState.searchManager.toggleLike(postID: postID)
                    case .profile:
                        await appState.profileManager.toggleLike(postID: postID)
                    }
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
                switch location {
                case .home, .user:
                    appState.postManager.sharePost(postID: postID)
                case .explore:
                    appState.searchManager.sharePost(postID: postID)
                case .profile:
                    appState.profileManager.sharePost(postID: postID)
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.foreground.opacity(Opacity.heavy))
            }
            
            Spacer()
            
            // MARK: - MENU
            Menu {
                Button("Copy Link") {
                    switch location {
                    case .home, .user:
                        appState.postManager.copyPostLink(postID: postID)
                    case .explore:
                        appState.searchManager.copyPostLink(postID: postID)
                    case .profile:
                        appState.profileManager.copyPostLink(postID: postID)
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.foreground.opacity(Opacity.heavy))
            }
        }
        .font(.smaller(.subheadline))
        .padding(.top, Padding.small)
        .padding(.trailing, Padding.tiny)
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
