//
//  SkylinerApp.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/29/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - MAIN
@main
struct SkylinerApp: App {
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RouterView()
                .environment(appState)
        }
    }
}
