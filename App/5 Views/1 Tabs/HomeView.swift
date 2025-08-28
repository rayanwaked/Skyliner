//
//  HomeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/27/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Environment(Coordinator.self) private var coordinator
    
    var body: some View {
        let posts = appState.postManager.homePosts
        
        ScrollView {
            ForEach(posts, id: \.postID) { post in
                Text(post.message)
            }
        }
    }
}

#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @State var coordinator = Coordinator()
    
    HomeView()
        .environment(appState)
        .environment(coordinator)
}
