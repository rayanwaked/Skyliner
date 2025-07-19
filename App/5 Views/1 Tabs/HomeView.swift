//
//  HomeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - VIEW
struct HomeView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @StateObject var headerManager = HeaderVisibilityManager()
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack {
                    PostFeature()
                    LoadMoreHelper(appState: appState, location: .home)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, Screen.height * 0.12)
            }
            .refreshable {
                Task {
                    await appState.postsManager.refreshPosts()
                }
            }
            .defaultScrollAnchor(.top)
            .scrollIndicators(.hidden)
            .headerScrollBehavior(headerManager)
            
            if headerManager.isVisible {
                HeaderFeature()
                    .zIndex(1)
                    .baselineOffset(headerManager.isVisible ? 0 : Screen.height * -1)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .offset(y: -Screen.height * 0.2).combined(with: .opacity)
                    ))
            }
        }
        .background(.standardBackground)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    HomeView()
        .environment(appState)
}
