//
//  RouterView.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/29/25.
//

// MARK: - IMPORTS
import SwiftUI
import ATProtoKit

// MARK: - VIEW
struct RouterView: View {
    @Environment(AppState.self) private var appState
    @State private var appLoaded: Bool = false
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            switch (appState.configuration != nil, appLoaded == true) {
            case (true, true):
                appNavigation
                    .transition(.opacity)
            case (false, true):
                AuthenticationView()
                    .environment(appState)
                    .transition(.opacity)
            case (true, false), (false, false):
                BackgroundComponent()
            }
        }
        .animation(.easeInOut, value: appLoaded)
        .task {
            while !appLoaded {
                if appState.configuration != nil {
                    try? await Task.sleep(for: .seconds(4))
                    appLoaded = true
                } else {
                    try? await Task.sleep(for: .seconds(1))
                }
            }
        }
    }
}

// MARK: - HOME VIEW + APP NAVIGATION
extension RouterView {
    var appNavigation: some View {
        ZStack(alignment: .bottom) {
            HomeView()
                .environment(appState)
            TabBarComponent()
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    RouterView()
        .environment(appState)
}
