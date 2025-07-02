//
//  HomeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - IMPORTS
import SwiftUI
import ATProtoKit

// MARK: - VIEW
struct HomeView: View {
    @Environment(AppState.self) private var appState
    
    // MARK: - BODY
    var body: some View {
        VStack {
            HeaderComponent(feeds: appState.feedModel, trends: appState.trendModel)
            Button("Log Out") {
                Task {
                    try await appState.authenticationManager.logout()
                }
            }
            FeedComponent(feed: appState.postModel)
        }
        .background(.defaultBackground)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    HomeView()
        .environment(appState)
}
