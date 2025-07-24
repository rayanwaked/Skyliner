//
//  ExploreView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import PostHog
import ATProtoKit

// MARK: - VIEW
struct ExploreView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    // MARK: - COMPUTED PROPERTIES
    private var posts: [(postID: String, imageURL: URL?, name: String, handle: String, time: String, message: String, embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?)] {
        appState.searchManager.postData
    }
    
    private var trends: [String] {
        appState.trendsManager.trends
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            if posts.isEmpty {
                VStack {
                    WeatherFeature()
                    trending
                }
            } else {
                results
            }
            
            HeaderFeature(location: .explore)
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

// MARK: - TRENDING
extension ExploreView {
    var trending: some View {
        VStack(alignment: .leading) {
            Text("Trending")
                .font(.smaller(.title3))
                .bold()
                .padding(.bottom, Padding.tiny)
            
            ForEach(Array(trends.enumerated()), id: \.offset) { index, trend in
                HStack {
                    Text("\(index + 1). ")
                        .bold()
                    Text("\(trend)")
                }
                .font(.smaller(.body))
                .padding(.vertical, Padding.tiny)
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
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Padding.standard)
        .padding(.top, Padding.large)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            PostHogSDK.shared.capture("Explore View")
        }
    }
}

// MARK: - RESULTS
extension ExploreView {
    var results: some View {
        ScrollView {
            LazyVStack {
                PostFeature(location: .explore)
                LoadMoreHelper(appState: appState, location: .explore)
            }
            .padding(.top, Screen.height * 0.07)
        }
        .scrollIndicators(.hidden)
        .transition(.asymmetric(
            insertion: .push(from: .top),
            removal: .move(edge: .bottom)
        ))
        .transition(.opacity)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
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
