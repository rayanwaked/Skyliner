//
//  ThreadFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/25/25.
//

import SwiftUI

// MARK: - VIEW
struct ThreadFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let postURI: String
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var threadManager: ThreadManager {
        appState.threadManager
    }
    
    // MARK: - BODY
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    loadingView
                } else if showError {
                    errorView
                } else {
                    threadContent
                }
            }
            .background(.standardBackground)
        }
        .task {
            await loadThread()
        }
    }
}

// MARK: - LOADING VIEW
extension ThreadFeature {
    var loadingView: some View {
        VStack(spacing: Padding.standard) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading thread...")
                .font(.smaller(.subheadline))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ERROR VIEW
extension ThreadFeature {
    var errorView: some View {
        VStack(spacing: Padding.standard) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text("Unable to load thread")
                .font(.headline)
            
            Text(errorMessage)
                .font(.smaller(.subheadline))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ButtonComponent("Try Again", variation: .secondary, size: .compact) {
                Task {
                    await loadThread()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - THREAD CONTENT
extension ThreadFeature {
    var threadContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Parent post if available
                if let parentPost = threadManager.parentPost {
                    ThreadPostCell(
                        post: parentPost,
                        isMainPost: true,
                        threadItem: nil
                    )
                    .padding(.bottom, Padding.small)
                    
                    Divider()
                        .padding(.horizontal, Padding.standard)
                }
                
                // Thread posts
                ForEach(Array(threadManager.threads.enumerated()), id: \.element.post.postID) { index, threadItem in
                    VStack(spacing: 0) {
                        ThreadPostCell(
                            post: threadItem.post,
                            isMainPost: false,
                            threadItem: threadItem
                        )
                        
                        if index < threadManager.threads.count - 1 {
                            Divider()
//                                .padding(.leading, threadLeadingPadding(for: threadItem.depth))
                                .padding(.horizontal, Padding.standard)
                        }
                    }
                }
            }
            .padding(.vertical, Padding.small)
        }
//        .refreshable {
//            await refreshThread()
//        }
    }
    
    private func threadLeadingPadding(for depth: Int) -> CGFloat {
        CGFloat(max(0, depth)) * 40 + 60
    }
}

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
                            .padding(.leading, Padding.tiny)
                    }
                    
                    if let parentAuthor = threadItem.parentAuthor {
                        Text("Replying to @\(parentAuthor)")
                            .font(.smaller(.caption))
                            .foregroundStyle(.secondary)
                            .padding(.leading, Padding.small)
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
                    PostActionBar(
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
            
            // Show reply indicator
            if let threadItem = threadItem, threadItem.hasMoreReplies {
                HStack {
                    if threadItem.depth >= 0 {
                        HStack(spacing: 0) {
                            ForEach(0...threadItem.depth, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: Padding.tiny)
                            }
                        }
                    }
                    
                    Text("\(Image(systemName: "arrow.turn.down.right")) More replies")
                        .font(.smaller(.caption))
                        .foregroundStyle(.blue)
                        .padding(.leading, Padding.small)
                    
                    Spacer()
                }
                .padding(.horizontal, Padding.standard)
                .padding(.top, Padding.tiny)
            }
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

// MARK: - POST ACTION BAR
struct PostActionBar: View {
    let manager: PostManaging
    let postID: String
    @Binding var isLiked: Bool
    @Binding var isReposted: Bool
    @Binding var likeCount: Int
    @Binding var repostCount: Int
    @Binding var replyCount: Int
    
    var body: some View {
        HStack {
            // Reply
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
            
            // Repost
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
            
            // Like
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
            
            // Share
            Button {
                manager.sharePost(postID: postID)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.foreground.opacity(Opacity.heavy))
            }
            
            Spacer()
            
            // Menu
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

// MARK: - METHODS
extension ThreadFeature {
    private func loadThread() async {
        isLoading = true
        showError = false
        
        await threadManager.loadThread(uri: postURI)
        
        withAnimation {
            isLoading = false
            if !threadManager.hasThreadData {
                showError = true
                errorMessage = "Could not load the thread. It may have been deleted or made private."
            }
        }
    }
    
    private func refreshThread() async {
        await threadManager.refreshThread(uri: postURI)
    }
}

// MARK: - THREAD MANAGER EXTENSION
extension ThreadManager: PostManaging {
    var displayPosts: [PostItem] {
        threads.map { $0.post }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    ThreadFeature(postURI: "at://did:example/app.bsky.feed.post/example")
        .environment(appState)
        .environment(routerCoordinator)
}
