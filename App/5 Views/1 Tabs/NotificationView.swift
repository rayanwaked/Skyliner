//
//  NotificationView.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/29/25.
//

import SwiftUI

// MARK: - VIEW
struct NotificationView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(Coordinator.self) private var coordinator
    
    var notifications: [NotificationItem] {
        appState.notificationsManager.notifications
    }
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading) {
            Text("Notifications")
                .font(.smaller(.title).bold())
                .padding(.leading, Padding.standard)
            
            NotificationFeature(notifications: notifications)
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @State var coordinator = Coordinator()
    
    NotificationView()
        .environment(appState)
        .environment(coordinator)
}
