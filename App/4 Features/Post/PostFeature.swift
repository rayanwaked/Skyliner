//
//  PostFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit

// MARK: - POST MANAGER PROTOCOL
protocol PostManaging {
    var displayPosts: [PostItem] { get }
    func getPostState(postID: String) -> PostState
    func toggleLike(postID: String) async
    func toggleRepost(postID: String) async
    func sharePost(postID: String)
    func copyPostLink(postID: String)
}

// MARK: - MANAGER EXTENSIONS
extension PostManager: PostManaging {
    var displayPosts: [PostItem] { homePosts }
}

extension SearchManager: PostManaging {
    var displayPosts: [PostItem] { searchPosts }
}

extension UserManager: PostManaging {
    var displayPosts: [PostItem] { userPosts }
}

extension ProfileManager: PostManaging {
    var displayPosts: [PostItem] { profilePosts }
}

// MARK: - VIEW
struct PostFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    let location: Location
    
    enum Location {
        case home, explore, user, profile
    }
    
    private var manager: PostManaging {
        switch location {
        case .home: return appState.postManager
        case .explore: return appState.searchManager
        case .user: return appState.userManager
        case .profile: return appState.profileManager
        }
    }
    
    // MARK: - BODY
    var body: some View {
        if !manager.displayPosts.isEmpty {
            LazyVStack {
                ForEach(manager.displayPosts, id: \.postID) { post in
                    PostCell(post: post, manager: manager)
                }
            }
        }
    }
}

// MARK: - POST CELL
struct PostCell: View {
    @Environment(AppState.self) var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    let post: PostItem
    let manager: PostManaging
    
    @State var isLiked = false
    @State var isReposted = false
    @State var likeCount = 0
    @State var repostCount = 0
    @State var replyCount = 0
    
    var body: some View {
        Group {
            Button {
                routerCoordinator.showThread(uri: post.postID)
                hapticFeedback(.light)
            } label: {
                HStack(alignment: .top) {
                    ProfilePictureComponent(isUser: false, profilePictureURL: post.imageURL, size: .medium)
                        .padding(.trailing, Padding.tiny)
                        .onTapGesture {
                            withAnimation(.bouncy(duration: 0.5)) {
                                appState.profileManager.userDID = post.authorDID
                                routerCoordinator.showingProfile = true
                            }
                            hapticFeedback(.light)
                        }
                    
                    VStack(alignment: .leading, spacing: Padding.tiny) {
                        HStack(alignment: .center) {
                            Text(post.name)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            Text("@\(post.handle)")
                                .foregroundStyle(.gray.opacity(0.9))
                                .lineLimit(1)
                            Text("· \(post.time)")
                                .foregroundStyle(.gray.opacity(0.9))
                        }
                        
                        if !post.message.isEmpty {
                            Text(post.message)
                                .multilineTextAlignment(.leading)
                        }
                        
                        if post.embed != nil {
                            PostEmbed(embed: post.embed)
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
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(.standardBackground)
            
            Divider()
        }
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

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    ScrollView {
        PostFeature(location: .home)
            .environment(appState)
            .environment(routerCoordinator)
    }
    .sheet(isPresented: $routerCoordinator.showingThread) {
        if !routerCoordinator.threadPostURI.isEmpty {
            ThreadFeature(postURI: routerCoordinator.threadPostURI)
                .environment(appState)
                .environment(routerCoordinator)
        }
    }
}
