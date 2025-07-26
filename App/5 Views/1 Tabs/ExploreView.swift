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
    private var hasSearchResults: Bool {
        !appState.searchManager.searchPosts.isEmpty
    }
    
    private var trends: [String] {
        appState.trendsManager.trends
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            if !hasSearchResults {
                VStack {
                    HeaderFeature(location: .explore)
                    //                        .padding(.bottom, Padding.standard)
                    //                    WeatherFeature()
                    trending
                }
            } else {
                results
                    .transition(.move(edge: .bottom).animation(.bouncy))
            }
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
        .padding(.top, Padding.standard)
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            PostHogSDK.shared.capture("Explore View")
        }
    }
}

// MARK: - RESULTS
extension ExploreView {
    var results: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack {
                    PostFeature(location: .explore)
                    LoadMoreHelper(appState: appState, location: .explore)
                }
                .padding(.top, Padding.large)
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
            
            ShadowOverlay()
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
