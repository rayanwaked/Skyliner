//
//  TabBarComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

// MARK: - IMPORTS
import SwiftUI
import NukeUI
internal import Combine

// MARK: - ROUTER VIEW MODEL
class TabBarViewModel: Observable, ObservableObject {
    @Published fileprivate var _selectedTab: Tabs = .home
    
    public var selectedTab: Tabs {
        get { _selectedTab }
        set { _selectedTab = newValue }
    }
    
    public enum Tabs: CaseIterable, Identifiable, Hashable {
        var id: Self { self }
        case home
        case explore
        case notifications
        case profile
        
        func systemImage(forSelected selected: Bool) -> String {
            switch self {
            case .home:
                return selected ? "bubble.fill" : "bubble"
            case .explore:
                return selected ? "binoculars.fill" : "binoculars"
            case .notifications:
                return selected ? "bell.fill" : "bell"
            case .profile:
                return selected ? "person.crop.circle.fill" : "person"
            }
        }
    }
}

// MARK: - MAIN TAB BAR COMPONENT
struct TabBarComponent: View {
    @Environment(TabBarViewModel.self) private var viewModel
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var exploreSearch: String = ""
    @StateObject private var keyboard = KeyboardResponder()
    
    // MARK: - BODY
    var body: some View {
        HStack {
            tabBarManager
            // MARK: - Action Button
            CompactButtonComponent(
                action: {},
                label: Image(systemName: "plus"),
                variation: .primary,
                placement: .tabBar
            )
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .padding(.bottom, keyboard.currentHeight > 0 ? PaddingConstants.smallPadding : -PaddingConstants.smallPadding)
        .shadow(
            color: colorScheme == .light ? .black.opacity(0.25) : .black.opacity(0.8),
            radius: RadiusConstants.defaultRadius,
            x: 0,
            y: PaddingConstants.defaultPadding * 2.5
        )
    }
}

// MARK: - TAB BAR MANAGER
extension TabBarComponent {
    private var tabBarManager: some View {
        HStack {
            if viewModel.selectedTab != .explore {
                tabBar
                    .transition(.move(edge: .leading))
            } else {
                exploreBar
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
    }
}

// MARK: - TAB BAR BUTTON
extension TabBarComponent {
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
                            .padding(.trailing, SizeConstants.screenWidth * 0.05)
                            .padding(.leading, SizeConstants.screenWidth * 0.04)
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
}

// MARK: - REGULAR TAB BAR
extension TabBarComponent {
    private var tabBar: some View {
        HStack {
            ForEach(TabBarViewModel.Tabs.allCases) { tab in
                if tab == .profile {
                    TabBarButton(
                        systemImage: "",
                        avatarURL: appState.profileModel.first?.avatar,
                        selected: viewModel.selectedTab == tab,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedTab = tab
                            }
                        }
                    )
                } else {
                    TabBarButton(
                        systemImage: tab.systemImage(forSelected: viewModel.selectedTab == tab),
                        avatarURL: nil,
                        selected: viewModel.selectedTab == tab,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedTab = tab
                            }
                        }
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

// MARK: - EXPLORE SEARCH BAR
extension TabBarComponent {
    private var exploreBar: some View {
        HStack {
            CompactButtonComponent(
                action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        dismissKeyboard()
                        viewModel.selectedTab = .home
                    }
                },
                label: Image(systemName: "chevron.left"),
                variation: .secondary,
                placement: .explore
            )
            InputFieldComponent(
                searchBar: true,
                icon: Image(systemName: "magnifyingglass"),
                title: "Explore the skies",
                text: $exploreSearch
            )
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var viewModel: TabBarViewModel = .init()
    
    TabBarComponent()
        .environment(viewModel)
        .environment(appState)
}
