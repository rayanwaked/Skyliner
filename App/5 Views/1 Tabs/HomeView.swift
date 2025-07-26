//
//  HomeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import PostHog

// MARK: - VIEW
struct HomeView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(HeaderCoordinator.self) private var headerCoordinator
    @StateObject var headerManager = HeaderVisibilityManager()
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack {
                    PostFeature(location: .home)
                    LoadMoreHelper(appState: appState, location: .home)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(
                    .top,
                    headerCoordinator.showingTrends ? Screen.height * 0.12 : Screen.height * 0.07
                )
            }
            .refreshable {
                Task {
                    await appState.postManager.refreshPosts()
                    hapticFeedback(.success)
                }
            }
            .defaultScrollAnchor(.top)
            .scrollIndicators(.hidden)
            .headerScrollBehavior(headerManager)
            
            if headerManager.isVisible {
                HeaderFeature()
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .offset(y: -Screen.height * 0.2).combined(with: .opacity)
                    ))
            } else {
                ShadowOverlay()
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .offset(y: -Screen.height * 0.2).combined(with: .opacity)
                    ))
            }
        }
        .background(.standardBackground)
        .onAppear {
            PostHogSDK.shared.capture("Home View")
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    @Previewable @State var headerCoordinator: HeaderCoordinator = .init()
    
    HomeView()
        .environment(appState)
        .environment(routerCoordinator)
        .environment(headerCoordinator)
}
