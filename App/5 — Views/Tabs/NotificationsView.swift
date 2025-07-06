//
//  NotificationsView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/2/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - VIEW
struct NotificationsView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Button("Log Out") {
            Task {
                try await appState.authenticationManager.logout()
            }
        }
        NotificationsComponent()
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    NotificationsView()
        .environment(appState)
}
