//
//  HomeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/27/25.
//

import SwiftUI

// MARK: - VIEW
struct HomeView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(Coordinator.self) private var coordinator
    
    var homeFeed: [PostItem] {
        appState.postManager.homePosts
    }

    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading) {
            Text("Home")
                .font(.smaller(.title).bold())
                .padding(.leading, Padding.standard)
            
            FeedFeature(feed: homeFeed)
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @State var coordinator = Coordinator()
    
    HomeView()
        .environment(appState)
        .environment(coordinator)
}
