//
//  TabBarComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

// MARK: - IMPORTS
import SwiftUI
import NukeUI

// MARK: - VIEWS
struct TabBarComponent: View {
    @Environment(RouterViewModel.self) private var routerViewModel
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var exploreSearch: String = ""
    
    // MARK: - BODY
    var body: some View {
        HStack {
            tabBarManager
            // MARK: - Action
            CompactButtonComponent(
                action: {},
                label: Image(systemName: "plus"),
                variation: .primary, placement: .tabBar
            )
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .padding(.bottom, -PaddingConstants.smallPadding)
        .shadow(
            color: colorScheme == .light ? .black
                .opacity(0.25) : .black
                .opacity(0.8),
            radius: RadiusConstants.defaultRadius,
            x: 0,
            y: PaddingConstants.defaultPadding * 2.5
        )
    }
}

// MARK: - NAVIGATION
extension TabBarComponent {
    var tabBarManager: some View {
        HStack {
            if routerViewModel.selectedTab != .explore {
                tabBar
            } else {
                exploreBar
            }
        }
    }
}

extension TabBarComponent {
    var tabBar: some View {
        HStack {
            ForEach(RouterViewModel.Tabs.allCases) { tab in
                if tab == .profile {
                    TabBarButton(
                        systemImage: "",
                        avatarURL: appState.profileModel.first?.avatar,
                        selected: routerViewModel.selectedTab == tab,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                routerViewModel.selectedTab = tab
                            }
                        }
                    )
                } else {
                    TabBarButton(
                        systemImage: tab.systemImage(forSelected: routerViewModel.selectedTab == tab),
                        avatarURL: nil,
                        selected: routerViewModel.selectedTab == tab,
                        action: { withAnimation(.easeInOut(duration: 0.2)) { routerViewModel.selectedTab = tab } }
                    )
                }
            }
        }
        .foregroundStyle(.primary)
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .padding([.top, .bottom], PaddingConstants.defaultPadding / 3)
        .glassEffect(.regular.tint(.clear).interactive())
    }
}

extension TabBarComponent {
    var exploreBar: some View {
        HStack {
            CompactButtonComponent(
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dismissKeyboard()
                        routerViewModel.selectedTab = .home
                    }
                },
                label: Image(systemName: "chevron.left"),
                variation: .secondary,
                placement: .explore)
            InputFieldComponent(
                icon: Image(systemName: "magnifyingglass"),
                title: "Explore the skies",
                text: $exploreSearch
            )
        }
    }
}

// MARK: - TAB BAR BUTTON
private struct TabBarButton: View {
    let systemImage: String
    let avatarURL: URL?
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
            hapticFeedback(.soft)
        } label: {
            if let avatarURL {
                LazyImage(url: avatarURL) { result in
                    result.image?
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: SizeConstants.screenWidth * 0.08, height: SizeConstants.screenWidth * 0.08)
                        .padding([.leading, .trailing], SizeConstants.screenWidth * 0.04)
                }
            } else {
                Image(systemName: systemImage)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: SizeConstants.screenHeight * 0.05)
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerViewModel: RouterViewModel = .init()
    
    TabBarComponent()
        .environment(routerViewModel)
        .environment(appState)
}

