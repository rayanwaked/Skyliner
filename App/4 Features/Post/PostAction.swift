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
                Button("Copy Link") {
                    manager.copyPostLink(postID: post.postID)
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
