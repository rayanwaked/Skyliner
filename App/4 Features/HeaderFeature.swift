//
//  HeaderFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/24/25.
//

import SwiftUI
import NukeUI
internal import Combine

// MARK: - VIEW
struct HeaderFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    var location: headerLocation = .home
    
    enum headerLocation {
        case home, explore, notifications
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            if location == .home {
                settingsSection
                trendingSection
            } else {
                settingsSection
                    .padding(.bottom, Padding.small)
            }
            
            Divider()
        }
        .background(.standardBackground)
    }
}

// MARK: - SETTINGS SECTION
private extension HeaderFeature {
    var settingsSection: some View {
        HStack {
            Spacer()
        }
        .padding(.horizontal, Padding.standard)
        .padding(.top, Padding.large * 1.75)
        .overlay(
            HStack {
                Image("SkylinerEmoji")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Screen.width * 0.08, height: Screen.width * 0.08)
                Group {
                    switch location {
                    case .home: Text("Skyliner")
                    case .explore: Text("Explore")
                    case .notifications: Text("Notifications")
                    }
                }
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            },
            alignment: .bottomLeading)
        .padding(.leading, Padding.standard)
    }
}

// MARK: - TRENDING SECTION
private extension HeaderFeature {
    var trendingSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Padding.small) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.accent)
                    .padding(.trailing, -Padding.small)
                
                ArrayButtonComponent(
                    items: appState.trendsManager.trends,
                    content: { trend in
                        Text(trend)
                    },
                    action: { trend in
                        withAnimation(.easeInOut) {
                            routerCoordinator.selectedTab = .explore
                        }
                        // Setting the search value after a delay, so that the view has time to load; otherwise a bug will occur and the search will return empty
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            routerCoordinator.exploreSearch = trend
                        }
                    }
                )
            }
            .padding(.horizontal, Padding.standard)
        }
        .padding(.vertical, Padding.tiny)
        .scrollIndicators(.hidden)
    }
}

// MARK: - SCROLL HANDLER
@MainActor
final class HeaderVisibilityManager: ObservableObject {
    @Published private(set) var isVisible: Bool = true
    
    func updateVisibility(_ oldValue: Double, _ newValue: Double) {
        withAnimation(.easeInOut) {
            if newValue < Screen.height * 0.025 {
                isVisible = true
            } else {
                isVisible = newValue < oldValue
            }
        }
    }
}

struct HandleScrollModifer: ViewModifier {
    let headerManager: HeaderVisibilityManager
    
    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentOffset.y
            } action: { oldValue, newValue in
                headerManager
                    .updateVisibility(oldValue, newValue)
            }
    }
}

extension View {
    func headerScrollBehavior(_ manager: HeaderVisibilityManager) -> some View {
        modifier(HandleScrollModifer(headerManager: manager))
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    HeaderFeature()
        .environment(appState)
        .environment(routerCoordinator)
}
