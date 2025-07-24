//
//  PostFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI

// MARK: - VIEW
struct PostFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    
    let location: Location
    
    enum Location {
        case home, explore, profile
    }
    
    var posts: [(postID: String, imageURL: URL?, name: String, handle: String, message: String)] {
        switch location {
        case .home:
            return appState.postManager.postData
        case .explore:
            return appState.searchManager.postData
        case .profile:
            return appState.postManager.authorData
        }
    }
    
    // MARK: - BODY
    var body: some View {
        
        if !posts.isEmpty {
            return AnyView(
                LazyVStack {
                    ForEach(Array(posts.enumerated()), id: \.offset) { index, post in
                        PostCell(
                            postID: post.postID,
                            imageURL: post.imageURL,
                            name: post.name,
                            handle: post.handle,
                            message: post.message,
                            location: location
                        )
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

// MARK: - POST CELL
struct PostCell: View {
    @Environment(AppState.self) private var appState
    
    var postID: String
    var imageURL: URL? = nil
    var name: String = "Name"
    var handle: String = "account@bsky.social"
    var message: String = ""
    var location: PostFeature.Location
    
    // State variables for reactive UI updates
    @State private var isLiked: Bool = false
    @State private var isReposted: Bool = false
    @State private var likeCount: Int = 0
    @State private var repostCount: Int = 0
    @State private var replyCount: Int = 0
    
    var body: some View {
        Group {
            HStack(alignment: .top) {
                ProfilePictureComponent(isUser: false, profilePictureURL: imageURL, size: .medium)
                    .padding(.trailing, Padding.tiny)
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(name)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Text("@\(handle)")
                            .foregroundStyle(.gray.opacity(0.9))
                            .lineLimit(1)
                        // Time
                    }
                    .padding(.bottom, Padding.tiny * 0.1)
                    
                    Text(message)
                    
                    actions
                }
                .font(.smaller(.body))
                
                Spacer()
            }
            .padding(.leading, Padding.standard)
            .padding(.vertical, Padding.tiny / 2)
            .background(.standardBackground)
            
            Divider()
        }
        .onAppear {
            updatePostState()
        }
    }
    
    // MARK: - UPDATE POST STATE
    private func updatePostState() {
        let postState = switch location {
        case .home, .profile:
            appState.postManager.getPostState(postID: postID)
        case .explore:
            appState.searchManager.getPostState(postID: postID)
        }
        
        isLiked = postState.isLiked
        isReposted = postState.isReposted
        likeCount = postState.likeCount
        repostCount = postState.repostCount
        replyCount = postState.replyCount
    }
}

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

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    PostFeature(location: .home)
        .environment(appState)
}
