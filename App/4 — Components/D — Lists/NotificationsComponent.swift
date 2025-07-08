//
//  NotificationComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/5/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - VIEW
struct NotificationsComponent: View {
    @Environment(AppState.self) private var appState
    @State private var isLoading = false
    
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
        .task {
            await loadNotifications()
        }
    }
    
    private func loadNotifications() async {
        isLoading = true
        _ = await appState.notificationManager.fetchNotifications()
        isLoading = false
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    NotificationsComponent()
        .environment(appState)
}
