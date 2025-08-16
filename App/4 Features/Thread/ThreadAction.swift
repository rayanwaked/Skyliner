//
//  ThreadAction.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/15/25.
//

import SwiftUI

// MARK: - POST ACTION BAR
struct ThreadActionBar: View {
    let manager: PostManaging
    let postID: String
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
                    await manager.toggleRepost(postID: postID)
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
                    await manager.toggleLike(postID: postID)
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
                manager.sharePost(postID: postID)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.foreground.opacity(Opacity.heavy))
            }
            
            Spacer()
            
            // MARK: - MENU
            Menu {
                Button("Copy Link") {
                    manager.copyPostLink(postID: postID)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.foreground.opacity(Opacity.heavy))
            }
        }
        .font(.smaller(.subheadline))
    }
}
