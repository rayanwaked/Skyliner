//
//  SkylinerApp.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import PostHog

// MARK: - APP
@main
struct SkylinerApp: App {
    @State private var appState = AppState()
    @State private var routerCoordinator = RouterCoordinator()
    
    // MARK: - POSTHOG
    init() {
        let posthogKey = (Bundle.main.object(forInfoDictionaryKey: "posthogKey") as? String ?? "")
        let posthogHost = "https://us.i.posthog.com"
        let config = PostHogConfig(apiKey: posthogKey, host: posthogHost)
        
        PostHogSDK.shared.setup(config)
    }
    
    // MARK: - BODY
    var body: some Scene {
        WindowGroup {
            RouterView()
                .environment(appState)
                .environment(routerCoordinator)
        }
    }
}
