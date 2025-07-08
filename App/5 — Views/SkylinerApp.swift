//
//  SkylinerApp.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/29/25.
//

// MARK: - IMPORTS
import SwiftUI
import PostHog

// MARK: - MAIN
@main
struct SkylinerApp: App {
    @State private var appState = AppState()
    
    init() {
        let POSTHOG_API_KEY = (Bundle.main.object(forInfoDictionaryKey: "posthogKey") as? String ?? "")
        let POSTHOG_HOST = "https://us.i.posthog.com"
        
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        config.sessionReplay = true
        
        PostHogSDK.shared.setup(config)
    }
    
    var body: some Scene {
        WindowGroup {
            RouterView()
                .environment(appState)
        }
    }
}
