//
//  FeedComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - VIEW
struct FeedComponent: View {
    var feed: [PostModel]
    
    // MARK: - BODY
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(feed, id:\.self) { post in
                    PostComponent(post: post.self)
                }
            }
            .padding(.bottom, SizeConstants.screenHeight * 0.1)
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - PREVIEW
#Preview {
    FeedComponent(feed: PostModel.placeholders)
}
