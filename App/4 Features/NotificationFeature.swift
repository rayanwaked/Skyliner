//
//  NotificationFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/29/25.
//

import SwiftUI

// MARK: - VIEW
struct NotificationFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    var notifications: [NotificationItem]
    
    // MARK: - BODY
    var body: some View {
        ScrollView {
            ForEach(notifications, id: \.id) { notification in
                HStack {
                    ProfilePictureComponent(isUser: false, profilePictureURL: notification.author.avatarURL)
                    Text(notification.author.name)
                    Text(notification.subjectContent ?? "")
                    Text(notification.reason.displayText)
                    Text(notification.timestamp.formatted())
                }
            }
        }
        .scrollIndicators(.never)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    let notifications = appState.notificationsManager.notifications
    
    NotificationFeature(notifications: notifications)
        .environment(appState)
}
