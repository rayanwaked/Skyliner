//
//  PostActions.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/3/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - ACTIONS
extension PostComponent {
    var actions: some View {
        HStack {
            repostButton
            Spacer()
            commentButton
            Spacer()
            likeButton
            Spacer()
            shareButton
            Spacer()
            optionsButton
        }
        .font(.custom("actions", size: 14))
        .foregroundStyle(.primary.opacity(ColorConstants.darkOpaque))
        .padding(.top, PaddingConstants.tinyPadding)
        .padding(.bottom, PaddingConstants.tinyPadding / 4)
    }
}

// MARK: - REPOST BUTTON
extension PostComponent {
    var repostButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.trianglehead.2.clockwise")
                .hapticAction(.soft, perform: {})
            Text(post.repostCount.abbreviated)
        }
    }
}

// MARK: - COMMENT BUTTON
extension PostComponent {
    var commentButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "message")
                .hapticAction(.soft, perform: {})
            Text(post.replyCount.abbreviated)
        }
    }
}

// MARK: - LIKE BUTTON
extension PostComponent {
    var likeButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart")
                .hapticAction(
                    .soft,
                    perform: {
                        if let clientManager = appState.clientManager {
                            if let manager = appState.postManager.contextManager(forURI: post.uri, client: clientManager) {
                                Task {
                                    await manager.toggleLike()
                                }
                            }
                        }
                    }
                )
            Text(post.likeCount.abbreviated)
        }
    }
}

// MARK: - SHARE BUTTON
extension PostComponent {
    var shareButton: some View {
        Image(systemName: "square.and.arrow.up")
            .padding(.bottom, 4)
            .hapticAction(.soft, perform: {})
    }
}

// MARK: - OPTIONS BUTTON
extension PostComponent {
    var optionsButton: some View {
        Image(systemName: "command")
            .hapticAction(.soft, perform: {})
    }
}
