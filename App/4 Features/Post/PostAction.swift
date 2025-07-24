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
            Button {
                Task {
                    // Optimistic update
                    isReposted.toggle()
                    withAnimation(.bouncy()) {
                        repostCount += isReposted ? 1 : -1
                    }
                    
                    // Call appropriate manager method
                    switch location {
                    case .home, .profile:
                        await appState.postManager.toggleRepost(postID: postID)
                    case .explore:
                        await appState.searchManager.toggleRepost(postID: postID)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.trianglehead.2.clockwise")
                    Text("\(repostCount)")
                        .contentTransition(.numericText())
                }
                .foregroundStyle(isReposted ? .blue : .primary)
            }
            
            Spacer()
            
            Button {
                // Handle reply action
                Task {
                    // TODO: Implement reply functionality
                }
            } label: {
                HStack {
                    Image(systemName: "message")
                    Text("\(replyCount)")
                }
                .foregroundStyle(.foreground)
            }
            
            Spacer()
            
            Button {
                Task {
                    // Optimistic update
                    isLiked.toggle()
                    withAnimation(.bouncy()) {
                        likeCount += isLiked ? 1 : -1
                    }
                    
                    // Call appropriate manager method
                    switch location {
                    case .home, .profile:
                        await appState.postManager.toggleLike(postID: postID)
                    case .explore:
                        await appState.searchManager.toggleLike(postID: postID)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                    Text("\(likeCount)")
                        .contentTransition(.numericText())
                }
                .foregroundStyle(isLiked ? .red : .primary)
            }
            
            Spacer()
            
            Button {
                switch location {
                case .home, .profile:
                    appState.postManager.sharePost(postID: postID)
                case .explore:
                    appState.searchManager.sharePost(postID: postID)
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.foreground)
            }
            
            Spacer()
            
            Menu {
                Button("Copy Link") {
                    switch location {
                    case .home, .profile:
                        appState.postManager.copyPostLink(postID: postID)
                    case .explore:
                        appState.searchManager.copyPostLink(postID: postID)
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.foreground)
            }
        }
        .font(.smaller(.subheadline))
        .padding(.top, Padding.small)
        .padding(.trailing, Padding.standard)
    }
}
