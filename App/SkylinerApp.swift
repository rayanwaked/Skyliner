//
//  SkylinerApp.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import SwiftyBeaver
import PostHog

// MARK: - LOG
let log = SwiftyBeaver.self

// MARK: - APP
@main
struct SkylinerApp: App {
    // MARK: - PROPERTIES
    @State private var appState = AppState()
    
    // MARK: - INITALIZATION
    init() {
        // LOGGER
        let console = ConsoleDestination()
        log.addDestination(console)
        
        // POSTHOG
        let key = (Bundle.main.object(forInfoDictionaryKey: "posthogKey") as? String ?? "")
        let host = "https://us.i.posthog.com"
        let config = PostHogConfig(apiKey: key, host: host)
        
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
