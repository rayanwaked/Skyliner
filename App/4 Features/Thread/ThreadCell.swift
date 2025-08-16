//
//  ThreadCell.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/15/25.
//

import SwiftUI

// MARK: - THREAD POST CELL
struct ThreadPostCell: View {
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    let post: PostItem
    let isMainPost: Bool
    let threadItem: ThreadItem?
    
    @State private var isLiked = false
    @State private var isReposted = false
    @State private var likeCount = 0
    @State private var repostCount = 0
    @State private var replyCount = 0
    
    private var manager: PostManaging {
        appState.threadManager
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Reply indicator
            if let threadItem = threadItem, threadItem.depth > 0 {
                HStack(spacing: Padding.tiny) {
                    ForEach(0..<threadItem.depth, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2)
                            .padding(.leading, Padding.small)
                    }
                    
                    if let parentAuthor = threadItem.parentAuthor {
                        Text("Replying to @\(parentAuthor)")
                            .font(.smaller(.callout))
                            .foregroundStyle(.secondary)
                            .padding([.leading, .top], Padding.small)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, Padding.standard)
                .padding(.bottom, Padding.tiny)
            }
            
            // Post content
            HStack(alignment: .top, spacing: Padding.small) {
                // Thread line for replies
                if let threadItem = threadItem, threadItem.depth > 0 {
                    HStack(spacing: 0) {
                        ForEach(0..<threadItem.depth, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: Padding.tiny)
                        }
                    }
                }
                
                // Profile picture
                ProfilePictureComponent(
                    isUser: false,
                    profilePictureURL: post.imageURL,
                    size: isMainPost ? .medium : .small
                )
                .onTapGesture {
                    withAnimation(.bouncy(duration: 0.5)) {
                        appState.profileManager.userDID = post.authorDID
                        routerCoordinator.showingProfile = true
                    }
                    hapticFeedback(.light)
                }
                
                // Content
                VStack(alignment: .leading, spacing: Padding.small) {
                    // Author info
                    HStack {
                        Text(post.name)
                            .font(isMainPost ? .headline : .subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text("@\(post.handle)")
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(post.time)
                            .foregroundStyle(.secondary)
                    }
                    .font(.smaller(.body))
                    
                    // Message
                    if !post.message.isEmpty {
                        Text(post.message)
                            .font(isMainPost ? .body : .smaller(.body))
                            .padding(.top, Padding.tiny)
                    }
                    
                    // Embed
                    if post.embed != nil {
                        PostEmbed(embed: post.embed)
                            .padding(.top, Padding.small)
                    }
                    
                    // Actions
                    ThreadActionBar(
                        manager: manager,
                        postID: post.postID,
                        isLiked: $isLiked,
                        isReposted: $isReposted,
                        likeCount: $likeCount,
                        repostCount: $repostCount,
                        replyCount: $replyCount
                    )
                    .padding(.top, Padding.small)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Padding.standard)
            .padding(.vertical, isMainPost ? Padding.standard : Padding.small)
            
//            // Show reply indicator
//            if let threadItem = threadItem, threadItem.hasMoreReplies {
//                HStack {
//                    if threadItem.depth >= 0 {
//                        HStack(spacing: 0) {
//                            ForEach(0...threadItem.depth, id: \.self) { _ in
//                                Rectangle()
//                                    .fill(Color.clear)
//                                    .frame(width: Padding.tiny)
//                            }
//                        }
//                    }
//                    
//                    Text("\(Image(systemName: "arrow.turn.down.right")) More replies")
//                        .font(.smaller(.callout))
//                        .foregroundStyle(.blue)
//                        .padding(.leading, Padding.small)
//                    
//                    Spacer()
//                }
//                .padding(.horizontal, Padding.standard)
//                .padding(.top, Padding.tiny)
//            }
        }
        .background(isMainPost ? Color.blue.opacity(0.05) : Color.clear)
        .onAppear {
            let state = manager.getPostState(postID: post.postID)
            isLiked = state.isLiked
            isReposted = state.isReposted
            likeCount = state.likeCount
            repostCount = state.repostCount
            replyCount = state.replyCount
        }
    }
}
