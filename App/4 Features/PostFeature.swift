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
    
    // MARK: - BODY
    var body: some View {
        let posts = appState.postManager.postData
        
        if !posts.isEmpty {
            return AnyView(
                LazyVStack {
                    ForEach(Array(posts.enumerated()), id: \.offset) { index, post in
                        PostCell(
                            postID: post.postID,
                            imageURL: post.imageURL,
                            name: post.name,
                            handle: post.handle,
                            message: post.message
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
    
    var body: some View {
        let postState = appState.postManager.getPostState(postID: postID)
        
        Group {
            HStack(alignment: .top) {
                ProfilePictureComponent(isUser: false, profilePictureURL: imageURL, size: .medium)
                    .padding(.trailing, Padding.tiny)
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(name)
                            .fontWeight(.medium)
                        Text("@\(handle)")
                            .foregroundStyle(.gray.opacity(0.9))
                            .lineLimit(1)
                        // Time
                    }
                    .padding(.bottom, Padding.tiny * 0.1)
                    
                    Text(message)
                    
                    actions(postState: postState)
                }
                .font(.smaller(.body))
                
                Spacer()
            }
            .padding(.leading, Padding.standard)
            .padding(.vertical, Padding.tiny)
            .background(.standardBackground)
            
            Divider()
        }
    }
}

// MARK: - ACTIONS
extension PostCell {
    func actions(postState: (isLiked: Bool, isReposted: Bool, likeCount: Int, repostCount: Int)) -> some View {
        HStack {
            Button {
                Task {
                    await appState.postManager.toggleRepost(postID: postID)
                }
            } label: {
                Image(systemName: "arrow.trianglehead.2.clockwise")
                    .foregroundStyle(postState.isReposted ? .blue : .primary)
            }
            
            Spacer()
            
            Button {
                // Handle reply action
            } label: {
                Image(systemName: "message")
                    .foregroundStyle(.foreground)
            }
            
            Spacer()
            
            Button {
                Task {
                    await appState.postManager.toggleLike(postID: postID)
                }
            } label: {
                Image(systemName: postState.isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(postState.isLiked ? .red : .primary)
            }
            
            Spacer()
            
            Button {
                appState.postManager.sharePost(postID: postID)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.foreground)
            }
            
            Spacer()
            
            Menu {
                Button("Copy Link") {
                    appState.postManager.copyPostLink(postID: postID)
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
    
    PostFeature()
        .environment(appState)
}
