//
//  NotificationsView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/28/25.
//

import SwiftUI

// MARK: - VIEW
struct NotificationsView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(HeaderCoordinator.self) private var headerCoordinator
    @StateObject var headerManager = HeaderVisibilityManager()
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                NotificationFeature()
                    .padding(.top,
                        headerCoordinator.showingTrends ? Screen.height * 0.12 : Screen.height * 0.07
                    )
            }
            .scrollIndicators(.hidden)
            .headerScrollBehavior(headerManager)
            
            if headerManager.isVisible {
                HeaderFeature()
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .offset(y: -Screen.height * 0.2).combined(with: .opacity)
                    ))
            } else {
                ShadowOverlay()
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .offset(y: -Screen.height * 0.2).combined(with: .opacity)
                    ))
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var headerCoordinator: HeaderCoordinator = .init()
    
    NotificationsView()
        .environment(appState)
        .environment(headerCoordinator)
}
