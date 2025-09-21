//
//  RouterView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - VIEW
struct RouterView: View {
    @Environment(AppState.self) private var appState
    @State var tabs: Tab?
    
    enum Tab { case home, explore, notification, profile }
    
    var body: some View {
        ZStack {
            switch appState.authManager.configState {
            case .authenticated: authenticatedRouter
            case .unauthenticated: Text("Login")
            case .pending2FA: Text("Login 2FA")
            case .failed: Text("Login Failed")
            case .empty: Text("Login Empty")
            }
            
            TabBarFeature(
                userDID: appState.userDID ?? "",
                homeAction: { tabs = .home } ,
                exploreAction: { tabs = .explore },
                notificationAction: { tabs = .notification },
                profileAction: { tabs = .profile }
            )
            .padding(.bottom, -Padding.small)
        }
        .background(.standardBackground)
    }
}

// MARK: - AUTHENTICATION ROUTER
private extension RouterView {
    @ViewBuilder
    var authenticatedRouter: some View {
        switch tabs {
        case .none: HomeView()
        case .home: HomeView()
        case .explore: ExploreView()
        case .notification: NotificationsView()
        case .profile: ProfileView()
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    
    RouterView(tabs: .home)
        .environment(appState)
}
