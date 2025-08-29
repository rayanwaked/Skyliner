//
//  FeedFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/28/25.
//

import SwiftUI
import NukeUI

// MARK: - VIEW
struct FeedFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    var feed: [PostItem]
    
    // MARK: - BODY
    var body: some View {
        ScrollView {
            ForEach(feed, id: \.postID) { post in
                HStack {
                    postProfilePicture(postData: post)
                    
                    VStack {
                        postAuthor(postData: post)
                        postMessage(postData: post)
                        Divider()
                            .padding(.vertical, Padding.tiny)
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
        .padding(.horizontal, Padding.tiny)
    }
}

// MARK: - MESSAGE
extension FeedFeature {
    func postMessage(postData: PostItem) -> some View {
        VStack {
            Text(postData.message)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Padding.tiny)
    }
}

// MARK: - POST IMAGE
//extension FeedFeature {
//    func postImage(postData: PostItem) -> some View {
//        VStack {
//            if let embed = postData.embed {
//                
//                AsyncImage(url: embed) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(maxWidth: .infinity, maxHeight: Screen.height / 4)
//                } placeholder: {
//                    ProgressView()
//                }
//            }
//        }
//    }
//}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    let posts = appState.postManager.homePosts
    
    FeedFeature(feed: posts)
        .environment(appState)
}
