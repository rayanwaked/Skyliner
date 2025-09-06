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
            ForEach(notifications, id: \.id) { event in
                HStack {
                    eventProfilePicture(eventData: event)
                    
                    VStack {
                        eventAuthor(eventData: event)
                        eventContent(eventData: event)
                        Divider()
                            .padding(.vertical, Padding.tiny)
                    }
                }
            }
        }
        .scrollIndicators(.never)
    }
}

// MARK: - AUTHOR PROFILE PICTURE
extension NotificationFeature {
    func eventProfilePicture(eventData: NotificationItem) -> some View {
        VStack {
            ProfilePictureComponent(
                isUser: false,
                profilePictureURL: eventData.author.avatarURL
            )
            .padding(.leading, Padding.standard)
            
            Spacer()
        }
    }
}

// MARK: - AUTHOR HANDLE & NAME
extension NotificationFeature {
    func eventAuthor(eventData: NotificationItem) -> some View {
        HStack(spacing: 0) {
            // AUTHOR NAME & HANDLE
            Text(eventData.author.name)
            
            // POST DATE
            Text(" · \(eventData.formattedTimestamp)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Padding.tiny)
        .lineLimit(1)
    }
}

// MARK: - CONTENT
extension NotificationFeature {
    func eventContent(eventData: NotificationItem) -> some View {
        VStack(alignment: .leading) {
            Text(eventData.reason.displayText)
            Text(eventData.subjectContent ?? "")
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Padding.tiny)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    let notifications = appState.notificationsManager.notifications
    
    NotificationFeature(notifications: notifications)
        .environment(appState)
}
