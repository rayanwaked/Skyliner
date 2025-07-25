//
//  PostFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit

// MARK: - VIEW
struct PostFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    let location: Location
    
    enum Location {
        case home, explore, profile
    }
    
    var posts: [(postID: String, imageURL: URL?, name: String, handle: String, time: String, message: String, embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?)] {
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
                            time: post.time,
                            embed: post.embed,
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
    @Environment(AppState.self) var appState
    
    var postID: String
    var imageURL: URL? = nil
    var name: String = "Name"
    var handle: String = "account@bsky.social"
    var message: String = ""
    var time: String = ""
    var embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion? = nil
    var location: PostFeature.Location
    
    // State variables for reactive UI updates
    @State var isLiked: Bool = false
    @State var isReposted: Bool = false
    @State var likeCount: Int = 0
    @State var repostCount: Int = 0
    @State var replyCount: Int = 0
    
    var body: some View {
        Group {
            HStack(alignment: .top) {
                ProfilePictureComponent(isUser: false, profilePictureURL: imageURL, size: .medium)
                    .padding(.trailing, Padding.tiny)
                    .onTapGesture {
//                        appState.viewAccountManager.userDID = ""
                        ProfileView()
                        hapticFeedback(.light)
                    }
                
                VStack(alignment: .leading, spacing: Padding.tiny) {
                    HStack(alignment: .center) {
                        Text(name)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Text("@\(handle)")
                            .foregroundStyle(.gray.opacity(0.9))
                            .lineLimit(1)
                        Text("· \(time)")
                            .foregroundStyle(.gray.opacity(0.9))
                    }
                    
                    if !message.isEmpty {
                        Text(message)
                    }
                    
                    if embed != nil {
                        PostEmbed(embed: embed)
                            .padding(.top, Padding.small)
                    }
                    
                    actions
                }
                .font(.smaller(.body))
                
                Spacer()
            }
            .padding(.leading, Padding.standard)
            .padding(.trailing, Padding.small)
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

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    ScrollView {
        PostFeature(location: .home)
            .environment(appState)
            .environment(routerCoordinator)
    }
}
