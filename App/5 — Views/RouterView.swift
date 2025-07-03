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

// MARK: - VIEW
struct RouterView: View {
    // MARK: - VARIABLES
    @Environment(AppState.self) private var appState
    @State var routerViewModel: RouterViewModel = .init()
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
            switch routerViewModel.selectedTab {
            case .home:
                HomeView()
                    .environment(appState)
            case .search:
                SearchView()
                    .environment(appState)
            case .notifications:
                NotificationsView()
                    .environment(appState)
            case .profile:
                ProfileView()
                    .environment(appState)
            }
            TabBarComponent()
                .environment(routerViewModel)
        }
    }
}

// MARK: - VIEW MODEL
class RouterViewModel: Observable, ObservableObject {
    @Published public var selectedTab: Tabs = .home
    
    public enum Tabs: CaseIterable, Identifiable, Hashable {
        var id: Self { self }
        
        case home
        case search
        case notifications
        case profile
        
        func systemImage(forSelected selected: Bool) -> String {
            switch self {
            case .home:
                return selected ? "airplane.up.right" : "airplane"
            case .search:
                return selected ? "magnifyingglass.circle.fill" : "magnifyingglass"
            case .notifications:
                return selected ? "bell.fill" : "bell"
            case .profile:
                return selected ? "person.crop.circle.fill" : "person"
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    RouterView()
        .environment(appState)
}

