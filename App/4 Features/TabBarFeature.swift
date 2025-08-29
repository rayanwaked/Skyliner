//
//  TabBarFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

import SwiftUI
import NukeUI
internal import Combine

extension Coordinator {
    var selectedTab: Tabs {
        get {
            switch currentView {
            case .home: return .home
            case .notifications: return .notifications
            case .user: return .user
            case .explore: return .explore
            }
        }
        set {
            switch newValue {
            case .home: currentView = .home
            case .notifications: currentView = .notifications
            case .user: currentView = .user
            case .explore: currentView = .explore
            }
        }
    }
}

// MARK: - ENUM
enum Tabs: CaseIterable, Identifiable, Hashable {
    case home, explore, notifications, user
    
    var id: Self { self }
    
    func systemImage(forSelected selected: Bool) -> String {
        switch self {
        case .home: selected ? "bubble.fill" : "bubble"
        case .explore: selected ? "binoculars.fill" : "binoculars"
        case .notifications: selected ? "bell.fill" : "bell"
        case .user: selected ? "person.crop.circle.fill" : "person"
        }
    }
}

// MARK: - VIEW
struct TabBarFeature: View {
    // MARK: - PROPERTIES
    @Environment(Coordinator.self) private var coordinator
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var keyboard = KeyboardResponder()
    @State private var localInput = ""
    
    private var tabBarOpacity: CGFloat {
        if #available(iOS 26, *) { return 0 } else { return 1 }
    }
    
    // MARK: - BODY
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                HStack {
                    if coordinator.currentView != .explore {
                        regularTabBar
                            .transition(.move(edge: .leading))
                    } else {
                        exploreSearchBar
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .trailing).combined(with: .opacity)
                            ))
                    }
                }
                
                // Compose Button
                ButtonComponent(
                    systemName: "plus",
                    variation: .primary,
                    size: .tabBar,
                    haptic: .soft,
                    action: {}
                )
            }
            .padding(.horizontal, Padding.standard)
            .padding(.bottom, keyboard.currentHeight > 0 ? Padding.tiny : -Padding.small)
        }
        .shadow(
            color: colorScheme == .light ? .white.opacity(0.9) : .black.opacity(0.8),
            radius: Radius.standard,
            y: Padding.standard * 2.5
        )
    }
}

// MARK: - REGULAR TAB BAR
extension TabBarFeature {
    var regularTabBar: some View {
        HStack {
            ForEach(Tabs.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        coordinator.selectedTab = tab
                    }
                    hapticFeedback(.soft)
                } label: {
                    if tab == .user {
                        userTabContent
                    } else {
                        Image(systemName: tab.systemImage(forSelected: coordinator.selectedTab == tab))
                            .font(.smaller(.title2))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, Padding.standard)
        .padding(.vertical, Padding.standard / 3)
        .frame(height: Screen.height * 0.06)
        .backport.glassEffect(
            .tintedAndInteractive(color: .clear, isEnabled: true),
            fallbackBackground: .thickMaterial
        )
        .clipShape(RoundedRectangle(cornerRadius: 100))
    }
    
    // MARK: - PROFILE TAB CONTENT
    var userTabContent: some View {
        Group {
            if appState.userManager.profilePictureURL != nil {
                ProfilePictureComponent(size: .xsmall)
                    .padding(.trailing, Screen.width * 0.06)
                    .padding(.leading, Screen.width * 0.04)
            } else {
                Image(systemName: Tabs.user.systemImage(forSelected: coordinator.selectedTab == .user))
                    .font(.smaller(.title2))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: Screen.height * 0.05)
            }
        }
    }
}

// MARK: - EXPLORE SEARCH BAR
extension TabBarFeature {
    var exploreSearchBar: some View {
        HStack(alignment: .center) {
            ButtonComponent(
                systemName: "chevron.left",
                variation: .secondary,
                size: .compact,
                haptic: .soft,
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dismissKeyboard()
                        appState.searchManager.clearSearch()
                        coordinator.currentView = .home
                    }
                }
            )
            InputFieldComponent(
                searchBar: true,
                secure: false,
                icon: Image(systemName: "magnifyingglass"),
                title: "Explore the skies",
                text: $localInput
            )
            .onSubmit {
//                coordinator.exploreSearch = localInput
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @State var coordinator = Coordinator()
    
    TabBarFeature()
        .environment(appState)
        .environment(coordinator)
}
