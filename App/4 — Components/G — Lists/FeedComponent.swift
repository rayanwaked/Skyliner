//
//  FeedComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - Imports
import SwiftUI

struct FeedComponent: View {
    var posts: [PostComponent] = []
    
    var body: some View {
        ForEach(posts, id:\.id) { post in
            PostComponent(id: post.id, displayName: post.displayName, handle: post.handle, time: post.time, content: post.content)
        }
    }
}

#Preview {
    @Previewable @State var posts: [PostComponent] = [
        .init(id: "1", displayName: "Skyliner", handle: "skyline.app", time: "1h", content: "Hello, World!"),
        .init(id: "1", displayName: "Skyliner", handle: "skyline.app", time: "1h", content: "Ready for takeoff!"),
    ]
    
    FeedComponent(posts: posts)
}
