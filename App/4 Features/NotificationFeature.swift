//
//  NotificationFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/28/25.
//

import SwiftUI

// MARK: - VIEW
struct NotificationFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    // MARK: - BODY
    var body: some View {
        let notifications = appState.notificationsManager.notifications
        
        if notifications.isEmpty {
            EmptyView()
        } else {
            LazyVStack {
                ForEach(notifications) { notification in
                    NotificationRow(
                        notification: notification,
                        onProfileTap: { handleProfileTap(for: notification) }
                    )
                }
            }
            .padding(.bottom, Padding.large)
        }
    }
}

// MARK: - ACTIONS
private extension NotificationFeature {
    func handleProfileTap(for notification: NotificationItem) {
        withAnimation(.bouncy(duration: 0.5)) {
            appState.profileManager.userDID = notification.authorDID
            routerCoordinator.showingProfile = true
        }
        hapticFeedback(.light)
    }
}

// MARK: - NOTIFICATION ROW
private struct NotificationRow: View {
    let notification: NotificationItem
    let onProfileTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.tiny) {
            HStack(alignment: .top, spacing: 0) {
                ProfilePictureComponent(
                    isUser: false,
                    profilePictureURL: notification.authorPictureURL,
                    size: .small
                )
                .onTapGesture { onProfileTap() }
                .padding(.trailing, Padding.small)
                
                NotificationContent(notification: notification)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
                .padding(.top, Padding.tiny)
                .padding(.horizontal, -Padding.standard)
        }
        .padding(.horizontal, Padding.standard)
        .padding(.vertical, Padding.tiny)
        .padding(.bottom, Padding.tiny)
    }
}

// MARK: - NOTIFICATION CONTENT
private struct NotificationContent: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(notification.authorName) \(notification.reason)")
                    .font(.smaller(.body))
                
                Spacer()
                
                Text(DateHelper.formattedRelativeDate(from: notification.timestamp))
                    .font(.smaller(.body))
            }
            .padding(.bottom, Padding.tiny)
            
            if let subjectContent = notification.subjectContent {
                Text(subjectContent)
                    .font(.smaller(.body))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    NotificationFeature()
        .environment(appState)
        .environment(routerCoordinator)
}
