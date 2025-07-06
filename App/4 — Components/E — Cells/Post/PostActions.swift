//
//  PostActions.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/3/25.
//

// **MARK: - IMPORTS**
import SwiftUI

// **MARK: - ACTIONS**
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

// **MARK: - REPOST BUTTON**
extension PostComponent {
    var repostButton: some View {
        HStack(spacing: 4) {
            Image(systemName: contextManager?.model.isReposted == true ? "arrow.trianglehead.2.clockwise" : "arrow.trianglehead.2.clockwise")
                .foregroundStyle(contextManager?.model.isReposted == true ? .green : .primary.opacity(ColorConstants.darkOpaque))
                .scaleEffect(contextManager?.model.isReposted == true ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: contextManager?.model.isReposted)
                .hapticAction(.soft, perform: {
                    guard let clientManager = appState.clientManager,
                          let manager = appState.postManager.contextManager(forURI: post.uri, client: clientManager) else {
                        return
                    }
                    
                    Task {
                        await manager.toggleRepost()
                    }
                })
            Text((contextManager?.model.repostCount ?? post.repostCount).abbreviated)
                .foregroundStyle(contextManager?.model.isReposted == true ? .green : .primary.opacity(ColorConstants.darkOpaque))
                .animation(.easeInOut(duration: 0.2), value: contextManager?.model.isReposted)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

// **MARK: - COMMENT BUTTON**
extension PostComponent {
    var commentButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "message")
                .hapticAction(.soft, perform: {
                    // TODO: Implement comment/reply functionality
                    // This would typically navigate to a compose view or open a reply sheet
                })
            Text(post.replyCount.abbreviated)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

// **MARK: - LIKE BUTTON**
extension PostComponent {
    var likeButton: some View {
        HStack(spacing: 4) {
            Image(systemName: contextManager?.model.isLiked == true ? "heart.fill" : "heart")
                .foregroundStyle(contextManager?.model.isLiked == true ? .red : .primary.opacity(ColorConstants.darkOpaque))
                .scaleEffect(contextManager?.model.isLiked == true ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: contextManager?.model.isLiked)
                .hapticAction(
                    .soft,
                    perform: {
                        guard let clientManager = appState.clientManager,
                              let manager = appState.postManager.contextManager(forURI: post.uri, client: clientManager) else {
                            return
                        }
                        
                        Task {
                            await manager.toggleLike()
                        }
                    }
                )
            Text((contextManager?.model.likeCount ?? post.likeCount).abbreviated)
                .foregroundStyle(contextManager?.model.isLiked == true ? .red : .primary.opacity(ColorConstants.darkOpaque))
                .animation(.easeInOut(duration: 0.2), value: contextManager?.model.isLiked)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
    }
}

// **MARK: - SHARE BUTTON**
extension PostComponent {
    var shareButton: some View {
        Image(systemName: "square.and.arrow.up")
            .padding(.bottom, 4)
            .hapticAction(.soft, perform: {
                // Create share sheet with post content
                let shareText = """
                \(post.author.displayName ?? post.author.handle): \(post.content)
                
                Via Skyliner for Bluesky
                """
                
                // Get the current window scene for presenting share sheet
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = windowScene.windows.first else {
                    return
                }
                
                let activityVC = UIActivityViewController(
                    activityItems: [shareText],
                    applicationActivities: nil
                )
                
                // For iPad support
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = window
                    popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                
                window.rootViewController?.present(activityVC, animated: true)
            })
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
    }
}

// **MARK: - OPTIONS BUTTON**
extension PostComponent {
    var optionsButton: some View {
        Image(systemName: "command")
            .hapticAction(.soft, perform: {
                // TODO: Implement options menu
                // This could show a context menu with options like:
                // - Copy link
                // - Report post
                // - Mute/Block user
                // - etc.
            })
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
    }
}

// **MARK: - CONTEXT MANAGER HELPER**
extension PostComponent {
    /// Helper computed property to get the context manager for this post
    private var contextManager: PostManager.PostContextManager? {
        guard let clientManager = appState.clientManager else { return nil }
        return appState.postManager.contextManager(forURI: post.uri, client: clientManager)
    }
}
