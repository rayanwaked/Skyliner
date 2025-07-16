//
//  RouterView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - VIEW
struct RouterView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    // MARK: - BODY
    var body: some View {
        switch (routerCoordinator.isLoaded, appState.authManager.configState) {
        case (true, .empty): splashView
        case (true, .failed): AuthenticationView()
        case (true, .restored): appView
        case (false, _): splashView
        }
    }
}

// MARK: - SPLASH VIEW
extension RouterView {
    var splashView: some View {
        SplashComponent()
            .onAppear {
                withAnimation(Animation.easeInOut.delay(1.5)) {
                    routerCoordinator.isLoaded = true
                }
            }
    }
}

// MARK: - APP VIEW
extension RouterView {
    var appView: some View {
        ZStack {
            switch routerCoordinator.selectedTab {
            case .home:
                HomeView()
                    .transition(.move(edge: .bottom))
            case .explore:
                ExploreView()
                    .transition(.move(edge: .top))
            case .profile:
                ProfileView()
                    .transition(.move(edge: .bottom))
            }
            
            TabBarFeature()
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    RouterView()
        .environment(appState)
        .environment(routerCoordinator)
}
