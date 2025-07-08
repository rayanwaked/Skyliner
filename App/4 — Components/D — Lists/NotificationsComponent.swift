//
//  NotificationComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/5/25.
//

import SwiftUI

// MARK: - NotificationsComponent
struct NotificationsComponent: View {
    @Environment(AppState.self) private var appState
    @State private var isLoading = false
    
    // MARK: - Properties
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading notifications...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if appState.notificationManager.notifications.isEmpty {
                ContentUnavailableView(
                    "No Notifications",
                    systemImage: "bell.slash",
                    description: Text("You don't have any notifications yet.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(appState.notificationManager.notifications) { notification in
                            NotificationComponent(notification: notification)
                                .padding(.vertical, 8)
                            
                            Divider()
                        }
                    }
                }
                .refreshable {
                    await loadNotifications()
                }
            }
        }
        .background(.defaultBackground)
        .task {
            await loadNotifications()
        }
    }
    
    // MARK: - Private Methods
    private func loadNotifications() async {
        isLoading = true
        _ = await appState.notificationManager.fetchNotifications()
        isLoading = false
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    NotificationsComponent()
        .environment(appState)
}
