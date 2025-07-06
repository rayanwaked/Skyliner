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
        NavigationView {
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
                                NotificationRow(notification: notification)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                
                                Divider()
                                    .padding(.leading, 70)
                            }
                        }
                    }
                    .refreshable {
                        await loadNotifications()
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await loadNotifications()
                        }
                    }
                }
            }
        }
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

// MARK: - NotificationRow
struct NotificationRow: View {
    let notification: NotificationModel
    
    // MARK: - Properties
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            AsyncImage(url: notification.author.avatar) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                // Header with name and reason
                HStack {
                    Text(notification.author.displayName ?? notification.author.handle)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(reasonText(for: notification.reason))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Handle
                Text("@\(notification.author.handle)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Time
                Text(notification.indexedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .background(notification.isRead ? Color.clear : Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
    
    // MARK: - Private Methods
    private func reasonText(for reason: NotificationModel.NotificationReason) -> String {
        switch reason {
        case .like:
            return "liked your post"
        case .repost:
            return "reposted your post"
        case .follow:
            return "followed you"
        case .mention:
            return "mentioned you"
        case .reply:
            return "replied to your post"
        case .quote:
            return "quoted your post"
        case .starterpackJoined:
            return "joined via starter pack"
        case .verified:
            return "verified"
        case .unverified:
            return "unverified"
        case .likeViaRepost:
            return "liked via repost"
        case .repostViaRepost:
            return "reposted via repost"
        case .subscribedPost:
            return "subscribed post"
        case .other:
            return "interacted with you"
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    NotificationsComponent()
        .environment(appState)
}
