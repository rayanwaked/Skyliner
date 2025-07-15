//
//  HeaderFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/24/25.
//

import SwiftUI
import NukeUI

// MARK: - VIEW
struct HeaderFeature: View {
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    var location: headerLocation = .home
    
    enum headerLocation {
        case home, explore, notifications
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if location == .home {
                settingsSection
                trendingSection
            } else {
                settingsSection
                    .padding(.bottom, Padding.small)
            }
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
                
//                ArrayButtonComponent(
//                    items: ["", ""], content: { trend in
//                        withAnimation(.easeInOut) {
//                            routerCoordinator.selectedTab = .explore
//                        }
//                        // Setting the search value after a delay, so that the view has time to load; otherwise a bug will occur and the search returns will be empty
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            routerCoordinator.exploreSearch = "" ?? ""
//                        }
//                    }, action: { trend in
//                        Text("" ?? "")
//                    }
//                )
            }
            .padding(.horizontal, Padding.standard)
        }
        .padding(.vertical, Padding.small)
        .scrollIndicators(.hidden)
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

