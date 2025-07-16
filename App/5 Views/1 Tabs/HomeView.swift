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
    @StateObject var scrollHandler = HandleScrollChange()
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack {
                    PostFeature()
                    LoadMoreHelper(appState: appState, location: .home)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, Screen.height * 0.125)
            }
            .defaultScrollAnchor(.top)
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentOffset.y
            } action: { oldValue, newValue in
                scrollHandler
                    .updateVisibility(oldValue, newValue)
            }
            
            if scrollHandler.isVisible {
                HeaderFeature()
                    .zIndex(1)
                    .baselineOffset(scrollHandler.isVisible ? 0 : Screen.height * -1)
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
