//
//  NotificationFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 8/29/25.
//

import SwiftUI

// MARK: - VIEW
struct NotificationFeature: View {
    @Environment(AppState.self) private var appState
    var notification: NotificationItem
    
    var body: some View {
        HStack(alignment: .top) {
            ProfilePictureComponent(profilePictureURL: notification.author.avatarURL, size: .small)
                .padding(.trailing, Padding.tiny)
            Text("\(notification.author.name)")
            Text("\(notification.formattedTimestamp)")
            Text("\(notification.reason)")
        }
        .padding(.horizontal, Padding.standard)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    
    if let notification = appState.notificationsManager.notifications.first {
        NotificationFeature(notification: notification)
            .environment(appState)
    }
}
