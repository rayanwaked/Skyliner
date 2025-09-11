//
//  RouterView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

enum Gate {
    case splash
    case unauthenticated
    case authenticated
}

// MARK: - COORDINATOR
@Observable
final class RouterCoordinator {
    // MARK: - PROPERTIES
    var splashCompleted: Bool = false
    var selectedTab: Tabs = .home
    var showingCreate: Bool = false
    var showingProfile: Bool = false
    var showingSettings: Bool = false
    var showingThread: Bool = false
    var threadPostURI: String = ""
    var exploreSearch: String = ""
    var showingReply: Bool = false
    var replyPost: PostItem?
    
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
    
    func showThread(uri: String) {
        threadPostURI = uri
        showingThread = true
    }
    
    func showReply(for post: PostItem) {
        replyPost = post
        showingReply = true
    }
    
    func hideReply() {
        showingReply = false
        replyPost = nil
    }
}


// MARK: - VIEW

struct RouterView: View {
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    private var gate: Gate {
        if !routerCoordinator.splashCompleted { return .splash }
        switch appState.authManager.configState {
        case .authenticated: return .authenticated
        case .failed, .unauthenticated, .pending2FA: return .unauthenticated
        case .empty: return .splash
        }
    }
    
    var body: some View {
        switch gate {
        case .splash:
            splashView.id("splash")
        case .unauthenticated:
            AuthenticationView().id("auth")
        case .authenticated:
            appView.id("app")
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
            // Background workaround due to the iOS 26 rounded keyboard and transparency exposing system background colors
            Rectangle()
                .foregroundStyle(.standardBackground)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            switch routerCoordinator.selectedTab {
            case .home:
                HomeView()
                    .transition(.move(edge: .bottom))
            case .explore:
                ExploreView()
                    .transition(.move(edge: .top))
            case .notifications:
                NotificationsView()
                    .transition(.move(edge: .bottom))
            case .user:
                UserView()
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
    @Previewable @State var appState = AppState()
    @Previewable @State var routerCoordinator = RouterCoordinator()
    @Previewable @State var headerCoordinator = HeaderCoordinator()
    
    RouterView()
        .environment(appState)
        .environment(routerCoordinator)
        .environment(headerCoordinator)
}

