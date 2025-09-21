//
//  NotificationsView.swift
//  Skyliner
//
//  Created by Rayan Waked on 9/17/25.
//

import SwiftUI

// MARK: - VIEW
struct NotificationsView: View {
    @Environment(AppState.self) private var appState
    private var notificationsModel: NotificationsManager {
        appState.notificationsManager
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(notificationsModel.notifications, id: \.id) {
                    notification in
                    LazyVStack(alignment: .leading) {
                        NotificationFeature(notification: notification)
                    }
                }
                .padding(.top, Padding.large)
            }
            .background(.standardBackground)
            .scrollIndicators(.never)
            .navigationTitle("Notifications")
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    
    NotificationsView()
        .environment(appState)
}
