//
//  ContentView.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/29/25.
//

// MARK: - Imports
import SwiftUI

// MARK: - View
struct ContentView: View {
    @Environment(AppState.self) private var appState
    var body: some View {
        AuthenticationView()
            .environment(appState)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ContentView()
        .environment(appState)
}
