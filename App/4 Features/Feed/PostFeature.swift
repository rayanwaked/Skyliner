//
//  PostFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/28/25.
//

import SwiftUI

// MARK: - VIEW
struct PostFeature: View {
    @Environment(AppState.self) private var appState
    var feed: PostItem
    
    var body: some View {
        HStack(alignment: .top) {
            ProfilePictureComponent(
                profilePictureURL: feed.imageURL
            )
            
            VStack(alignment: .leading) {
                // Account Information
                HStack {
                    Text("\(feed.name)")
                    Text("\(feed.handle)")
                    Spacer()
                    Text("\(feed.time)")
                }
                .lineLimit(1)
                .padding(.bottom, Padding.tiny)
                
                // Post Content
                Text("\(feed.message)")
            }
            .padding(.leading, Padding.tiny)
        }
        .padding(.horizontal, Padding.standard)
        .padding(.bottom, Padding.standard)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    
    if let feed = appState.postManager.homePosts.first {
        PostFeature(feed: feed)
        .environment(appState)
    }
}
