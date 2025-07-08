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
    // MARK: - VARIABLES
    @State private var appState = AppState()
    
    // MARK: - INITALIZE
    init() {
        let POSTHOG_API_KEY = Bundle.main.object(forInfoDictionaryKey: "posthogKey") as? String ?? ""
        let POSTHOG_HOST = "https://us.i.posthog.com"
        
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        config.sessionReplay = true
        
        PostHogSDK.shared.setup(config)
    }
    
    // MARK: - BODY
    var body: some Scene {
        WindowGroup {
            RouterView()
                .environment(appState)
        }
    }
}
