//
//  PostFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI

struct PostFeature: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        postList
    }
}

// MARK: - POST LIST
extension PostFeature {
    var postList: some View {
        let posts = appState.postsManager.postData
        
        if !posts.isEmpty {
            return AnyView(
                LazyVStack {
                    ForEach(Array(posts.enumerated()), id: \.offset) { index, post in
                        PostCell(
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
    var imageURL: URL? = nil
    var name: String = "Name"
    var handle: String = "account@bsky.social"
    var message: String = ""
    
    var body: some View {
        Group {
            HStack(alignment: .top) {
                ProfilePictureComponent(isUser: false, profilePictureURL: imageURL, size: .medium)
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Text(name)
                        Text("· 2h ago")
                    }
                    Text(handle)
                        .padding(.bottom, Padding.tiny * 0.1)
                    
                    Text(message)
                }
                .font(.subheadline)
                
                Spacer()
            }
            .padding(.leading, Padding.standard)
            .padding(.vertical, Padding.small)
            .background(.standardBackground)
            
            Divider()
        }
    }
}

#Preview {
    @Previewable @State var appState: AppState = .init()
    
    PostFeature()
        .environment(appState)
}

