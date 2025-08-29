//
//  PostsFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/28/25.
//

import SwiftUI
import NukeUI

// MARK: - VIEW
struct PostsFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    var feed: [PostItem]
    
    // MARK: - BODY
    var body: some View {
        ScrollView {
            ForEach(feed, id: \.postID) { post in
                VStack {
                    postMessage(postData: post)
                    postAuthor(postData: post)
                }
            }
        }
    }
}

// MARK: - POST MESSAGE
extension PostsFeature {
    func postMessage(postData: PostItem) -> some View {
        VStack {
            Text(postData.message)
        }
    }
}

// MARK: - POST AUTHOR
extension PostsFeature {
    func postAuthor(postData: PostItem) -> some View {
        VStack {
            // AUTHOR PROFILE PICTURE
            AsyncImage(url: postData.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(Frame.small())
            } placeholder: {
                ProgressView()
            }
            
            // AUTHOR HANDLE & NAME
            Text(postData.handle)
            Text(postData.name)
            
            // POST DATE
            Text(postData.time)
        }
    }
}

// MARK: - POST IMAGE
//extension PostsFeature {
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
    
    PostsFeature(feed: posts)
        .environment(appState)
}
