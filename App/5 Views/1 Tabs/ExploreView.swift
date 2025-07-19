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
            let trends = appState.trendsManager.trends
            
            if !posts.isEmpty {
                ScrollView {
                    LazyVStack {
                        ForEach(Array(posts.enumerated()), id: \.offset) { index, post in
                            PostCell(
                                postID: post.postID,
                                imageURL: post.imageURL,
                                name: post.name,
                                handle: post.handle,
                                message: post.message
                            )
                        }
                    }
                    .padding(.top, Screen.height * 0.07)
                }
                .scrollIndicators(.hidden)
                .transition(.asymmetric(
                    insertion: .push(from: .top),
                    removal: .move(edge: .bottom)
                ))
            } else {
                VStack(alignment: .leading) {
                    ForEach(Array(trends.enumerated()), id: \.offset) { index, trend in
                        HStack {
                            Text("\(index + 1). ")
                                .bold()
                            Text("\(trend)")
                        }
                        .font(.smaller(.body))
                        .padding(.vertical, Padding.small)
                        .hapticAction(.light, perform: {
                            Task {
                                await appState.searchManager.searchBluesky(query: trend)
                                routerCoordinator.exploreSearch = trend
                            }
                        })
                        
                        Divider()
                    }
                    Spacer()
                }
                .transition(.opacity)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topLeading
                )
                .padding(.horizontal, Padding.standard)
                .padding(.top, Screen.height * 0.065)
            }
            
            HeaderFeature(location: .explore)
                .background(.red)
        }
        .background(.standardBackground)
        .onChange(of: routerCoordinator.exploreSearch) {_, newValue in
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
