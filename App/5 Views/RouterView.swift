//
//  RouterView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - COORDINATOR
@Observable
final class RouterCoordinator {
    // MARK: - PROPERTIES
    var splashCompleted: Bool = false
    var selectedTab: Tabs = .home
    var showingCreate: Bool = false
    var exploreSearch: String = ""
    
    // MARK: - METHODS
    func selectTab(_ tab: Tabs) {
        selectedTab = tab
    }
    
    func toggleCreate() {
        showingCreate.toggle()
    }
    
    func clearExploreSearch() {
        exploreSearch = ""
    }
}

// MARK: - VIEW
struct RouterView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    // MARK: - BODY
    var body: some View {
        switch (routerCoordinator.splashCompleted, appState.authManager.configState) {
        case (false, _): splashView.id("splash")
        case (true, .empty): splashView.id("splash")
        case (true, .failed): AuthenticationView().id("auth")
        case (true, .restored): appView
        }
    }
}

// MARK: - SPLASH VIEW
extension RouterView {
    var splashView: some View {
        SplashDesign()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        routerCoordinator.splashCompleted = true
                    }
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
        .transition(.move(edge: .bottom))
        .zIndex(-1)
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

