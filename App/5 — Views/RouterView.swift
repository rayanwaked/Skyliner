//
//  RouterView.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/29/25.
//

// MARK: - IMPORTS
import SwiftUI
import ATProtoKit
internal import Combine
import PostHog

// MARK: - VIEW
struct RouterView: View {
    // MARK: - VARIABLES
    @Environment(AppState.self) private var appState
    @State var viewModel: TabBarViewModel = .init()
    @State private var appLoaded: Bool = false
    
    // MARK: - BODY
    var body: some View {
        @State var configurationState = appState.authenticationManager.configurationState
        
        ZStack {
            switch (
                configurationState == .restored, appLoaded == true
            ) {
            case (true, true):
                appNavigation
                    .animation(.easeInOut(duration: 3), value: configurationState)
            case (false, true):
                AuthenticationView()
                    .environment(appState)
                    .animation(.easeInOut, value: configurationState)
            case (true, false), (false, false):
                ZStack {
                    BackgroundComponent()
                    SplashComponent()
                }
                .glassEffect(in: RoundedRectangle(
                    cornerRadius: RadiusConstants.glassRadius
                ))
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 3), value: configurationState)
            }
        }
        .onAppear { PostHogSDK.shared.capture("Test Event") }
        .animation(.easeInOut, value: appLoaded)
        .task {
            while !appLoaded {
                if configurationState == .restored {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation(.easeInOut(duration: 3)) {
                        appLoaded = true
                    }
                } else {
                    try? await Task.sleep(for: .seconds(1))
                    appLoaded = true
                }
            }
        }
    }
}

// MARK: - HOME VIEW + APP NAVIGATION
extension RouterView {
    var appNavigation: some View {
        ZStack(alignment: .bottom) {
            switch viewModel.selectedTab {
            case .home:
                HomeView()
                    .environment(appState)
                    .transition(.move(edge: .bottom))
            case .explore:
                ExploreView()
                    .environment(appState)
                    .transition(.move(edge: .bottom))
            case .notifications:
                NotificationsView()
                    .environment(appState)
                    .transition(.move(edge: .bottom))
            case .profile:
                ProfileView()
                    .environment(appState)
                    .transition(.push(from: .bottom))
            }
            TabBarComponent()
                .environment(viewModel)
                .environment(appState)
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    RouterView()
        .environment(appState)
}

