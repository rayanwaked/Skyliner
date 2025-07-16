//
//  ExploreView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - VIEW
struct ExploreView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            let posts = appState.searchManager.postData
            
            if !posts.isEmpty {
                ScrollView {
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
                    .padding(.top, Screen.height * 0.06)
                }
                .scrollIndicators(.hidden)
            } else {
                Rectangle()
                    .foregroundStyle(.standardBackground)
                    .ignoresSafeArea(.keyboard)
            }
            
            HeaderFeature(location: .explore)
        }
        .background(.standardBackground)
        .onChange(of: routerCoordinator.exploreSearch) {_, newValue in
            print("🔍🔄 ExploreView: Search query changed to: '\(newValue)'")
            Task {
                if !newValue.isEmpty {
                    await appState.searchManager.searchBluesky(
                        query: newValue
                    )
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    ExploreView()
        .environment(appState)
        .environment(routerCoordinator)
}
