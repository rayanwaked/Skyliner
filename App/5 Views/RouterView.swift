//
//  RouterView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - CONTROLLER
@Observable
class Coordinator {
    enum Views {
        case home, notifications, user
    }
    enum Sheets {
        case compose, profile
    }
    
    var currentView: Views = .home
    var currentSheet: Sheets = .compose
    var currentProfile: String = ""
    var showingSheet: Bool = false
}

// MARK: - VIEW
struct RouterView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(Coordinator.self) private var coordinator
    @State var splashCompleted: Bool = false
    
    // GATE
    enum Gate {
        case splash
        case unauthenticated
        case authenticated
    }
    private var gate: Gate {
        if !splashCompleted { return .splash }
        switch appState.authManager.configState {
        case .authenticated: return .authenticated
        case .failed, .unauthenticated, .pending2FA: return .unauthenticated
        case .empty: return .splash
        }
    }
    
    // MARK: - BODY
    var body: some View {
        switch gate {
        case .splash:
            splashView.id("splash")
        case .unauthenticated:
            AuthenticationView()
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        splashCompleted = true
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
                .zIndex(-1)
            
            Group {
                switch coordinator.currentView {
                case .home: HomeView()
                case .user: UserView()
                case .notifications: NotificationView()
                }
            }
            .blur(radius: coordinator.showingSheet ? 2 : 0)
            
            if !coordinator.showingSheet {
                TabBarFeature()
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
        .transition(.move(edge: .bottom))
        .zIndex(-1)
        .sheet(isPresented: Binding(
            get: { coordinator.showingSheet },
            set: { coordinator.showingSheet = $0 }
        )) {
            switch coordinator.currentSheet {
            case .compose:
                ComposeView()
            case .profile:
                ProfileView()
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @State var coordinator = Coordinator()
    
    RouterView()
        .environment(appState)
        .environment(coordinator)
}

