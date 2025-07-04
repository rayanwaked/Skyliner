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
            commentButton
            Spacer()
            repostButton
            Spacer()
            likeButton
            Spacer()
            shareButton
            Spacer()
            optionsButton
        }
    }
}

// MARK: - COMMENT BUTTON
extension PostComponent {
    var commentButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "message")
                .padding(7)
                .glassEffect(.regular.interactive(), in: Circle())
                .hapticAction(.soft, perform: {})
            Text(post.replyCount.description)
        }
        .font(.callout)
    }
}

// MARK: - REPOST BUTTON
extension PostComponent {
    var repostButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.trianglehead.2.clockwise")
                .padding(7)
                .glassEffect(.regular.interactive(), in: Circle())
                .hapticAction(.soft, perform: {})
            Text(post.repostCount.description)
        }
        .font(.callout)
    }
}

// MARK: - LIKE BUTTON
extension PostComponent {
    var likeButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart")
                .padding(7)
                .glassEffect(.regular.interactive(), in: Circle())
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
            Text(post.likeCount.description)
        }
        .font(.callout)
    }
}

// MARK: - SHARE BUTTON
extension PostComponent {
    var shareButton: some View {
        Image(systemName: "square.and.arrow.up")
            .font(.callout)
            .padding(.bottom, 4)
            .padding(7)
            .glassEffect(.regular.interactive(), in: Circle())
            .hapticAction(.soft, perform: {})
    }
}

// MARK: - OPTIONS BUTTON
extension PostComponent {
    var optionsButton: some View {
        Image(systemName: "command")
            .font(.callout)
            .padding(7)
            .glassEffect(.regular.interactive(), in: Circle())
            .hapticAction(.soft, perform: {})
    }
}
