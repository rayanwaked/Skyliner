//
//  TabBarComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - VIEWS
struct TabBarComponent: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(RouterViewModel.self) private var routerViewModel
    
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
            radius: LayoutConstants.defaultRadius,
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
                TabBarButton(
                    systemImage: tab.systemImage(forSelected: routerViewModel.selectedTab == tab),
                    selected: routerViewModel.selectedTab == tab,
                    action: { routerViewModel.selectedTab = tab }
                )
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
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
            hapticFeedback(.soft)
        } label: {
            Image(systemName: systemImage)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: SizeConstants.screenHeight * 0.05)
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var routerViewModel: RouterViewModel = .init()
    
    TabBarComponent()
        .environment(routerViewModel)
}
