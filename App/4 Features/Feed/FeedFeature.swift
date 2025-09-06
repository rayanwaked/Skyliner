//
//  FeedFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/28/25.
//

import SwiftUI

// MARK: - VIEW
struct FeedFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(Coordinator.self) private var coordinator
    var feed: [PostItem]
    
    // MARK: - BODY
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(feed, id: \.postID) { post in
                    HStack {
                        postProfilePicture(postData: post)
                        
                        VStack {
                            postAuthor(postData: post)
                            postMessage(postData: post)
                            PostEmbeds(embed: post.embed)
                            PostActions(postID: post.postID)
                            Divider()
                                .padding(.vertical, Padding.tiny)
                        }
                    }
                }
            }
        }
        .scrollIndicators(.never)
    }
}

// MARK: - AUTHOR PROFILE PICTURE
extension FeedFeature {
    func postProfilePicture(postData: PostItem) -> some View {
        VStack {
            ProfilePictureComponent(
                isUser: false,
                profilePictureURL: postData.imageURL
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.35)) {
                    coordinator.currentProfile = postData.authorDID
                    coordinator.currentSheet = .profile
                    coordinator.showingSheet = true
                }
            }
            .padding(.leading, Padding.standard)
            
            Spacer()
        }
    }
}

// MARK: - AUTHOR HANDLE & NAME
extension FeedFeature {
    func postAuthor(postData: PostItem) -> some View {
        HStack(spacing: 0) {
            // AUTHOR NAME & HANDLE
            Text(postData.name)
            Text(" @\(postData.handle)")
            
            // POST DATE
            Text(" · \(postData.time)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, Padding.tiny)
        .padding(.trailing, Padding.standard)
        .lineLimit(1)
        .font(.smaller(.body))
    }
}

// MARK: - MESSAGE
extension FeedFeature {
    func postMessage(postData: PostItem) -> some View {
        VStack {
            Text(postData.message)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 1)
        }
        .padding(.leading, Padding.tiny)
        .padding(.trailing, Padding.standard)
        .font(.smaller(.body))
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @State var coordinator = Coordinator()
    let posts = appState.postManager.homePosts
    
    FeedFeature(feed: posts)
        .environment(appState)
        .environment(coordinator)
}

