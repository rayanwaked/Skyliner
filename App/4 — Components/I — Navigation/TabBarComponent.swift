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
    
    // MARK: - BODY
    var body: some View {
        HStack {
            tabBarTabs
            // MARK: - Action
            CompactButtonComponent(
                action: {},
                label: Image(systemName: "plus"),
                variation: .primary, placement: .tabBar
            )
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .padding(.bottom, -10)
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
    var tabBarTabs: some View {
        HStack {
            ForEach(RouterViewModel.Tabs.allCases) { tab in
                if tab == .profile {
                    TabBarButton(
                        systemImage: "",
                        avatarURL: appState.profileModel.first?.avatar,
                        selected: routerViewModel.selectedTab == tab,
                        action: { routerViewModel.selectedTab = tab }
                    )
                } else {
                    TabBarButton(
                        systemImage: tab.systemImage(forSelected: routerViewModel.selectedTab == tab),
                        avatarURL: nil,
                        selected: routerViewModel.selectedTab == tab,
                        action: { routerViewModel.selectedTab = tab }
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
