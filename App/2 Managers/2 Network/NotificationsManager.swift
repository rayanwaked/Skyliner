//
//  NotificationsManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/28/25.
//

import SwiftUI
import ATProtoKit

// MARK: - ITEM
struct NotificationItem: Identifiable, Hashable, Equatable {
    var id: String { uri }
    let uri: String
    var reason: String
    let content: String
    let authorName: String
    let authorDID: String
    let authorPictureURL: URL?
    let timestamp: Date
    let isRead: Bool
}

@MainActor
@Observable
// MARK: - MANAGER
final class NotificationsManager {
    // MARK: - PROPERTIES
    @ObservationIgnored
    var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    
    // Store raw notifications privately
    @ObservationIgnored
    private var rawNotifications: AppBskyLexicon.Notification.ListNotificationsOutput?
    
    // Expose wrapped notifications
    var notifications: [NotificationItem] = []
    var reasons: [AppBskyLexicon.Notification.Notification.Reason]?
    var priority: Bool?
}

// MARK: - METHODS
extension NotificationsManager {
    func loadNotifications() async {
        do {
            if let fetched = try await appState?.clientManager?.account.listNotifications(
                with: reasons,
                limit: 50,
                isPriority: priority
            ) {
                rawNotifications = fetched
                
                // Convert ATProtoKit notifications to wrapper types
                notifications = fetched.notifications.compactMap { notification in
                    // Debug: Print the notification to see its actual structure
                    print("Notification type: \(type(of: notification))")
                    print("Notification: \(notification)")
                    
                    return NotificationItem(
                        uri: notification.uri,
                        reason: extractReason(from: notification.reason),
                        content: notification.reasonSubjectURI ?? "",
                        authorName: extractAuthor(from: notification.author),
                        authorDID: extractAuthorDID(from: notification.author),
                        authorPictureURL: extractAuthorImageURL(from: notification.author),
                        timestamp: notification.indexedAt,
                        isRead: notification.isRead
                    )
                }
            }
        } catch {
            print("Error loading notifications: \(error)")
        }
    }
    
    // MARK: - PRIVATE HELPERS
    private func extractContent(from notification: AppBskyLexicon.Notification.Notification) -> String {
        return "Content available"
    }
    
    private func extractReason(from reason: AppBskyLexicon.Notification.Notification.Reason) -> String {
        switch reason.rawValue {
        case "like": return "liked your post"
        case "reply": return "replied to you"
        case "repost": return "reposted you"
        case "mention": return "mentioned you"
        case "follow": return "followed you"
        default: return reason.rawValue
        }
    }
    
    private func extractAuthor(from author: AppBskyLexicon.Actor.ProfileViewDefinition) -> String {
        if author.displayName == "" {
            return "Unknown"
        }
        return author.displayName ?? "Unknown"
    }
    
    private func extractAuthorDID(from author: AppBskyLexicon.Actor.ProfileViewDefinition) -> String {
        return author.actorDID
    }
    
    private func extractAuthorImageURL(from author: AppBskyLexicon.Actor.ProfileViewDefinition) -> URL? {
        return author.avatarImageURL
    }
}
