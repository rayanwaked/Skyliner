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
    let subjectContent: String? // The actual post/record content
    let subjectURI: String? // URI of the subject (post/record)
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
            guard let fetched = try await appState?.clientManager?.account.listNotifications(
                with: reasons,
                limit: 50,
                isPriority: priority
            ) else { return }
            
            rawNotifications = fetched
            
            // Convert ATProtoKit notifications to wrapper types
            notifications = await withTaskGroup(of: NotificationItem?.self) { group in
                for notification in fetched.notifications {
                    group.addTask {
                        await self.createNotificationItem(from: notification)
                    }
                }
                
                var items: [NotificationItem] = []
                for await item in group {
                    if let item = item {
                        items.append(item)
                    }
                }
                return items.sorted { $0.timestamp > $1.timestamp }
            }
        } catch {
            print("Error loading notifications: \(error)")
        }
    }
    
    // MARK: - PRIVATE HELPERS
    private func createNotificationItem(from notification: AppBskyLexicon.Notification.Notification) async -> NotificationItem? {
        // Extract subject content based on notification type
        let subjectContent = await extractSubjectContent(from: notification)
        
        return NotificationItem(
            uri: notification.uri,
            reason: extractReason(from: notification.reason),
            content: notification.reasonSubjectURI ?? "",
            authorName: extractAuthor(from: notification.author),
            authorDID: extractAuthorDID(from: notification.author),
            authorPictureURL: extractAuthorImageURL(from: notification.author),
            timestamp: notification.indexedAt,
            isRead: notification.isRead,
            subjectContent: subjectContent,
            subjectURI: notification.reasonSubjectURI
        )
    }
    
    private func extractSubjectContent(from notification: AppBskyLexicon.Notification.Notification) async -> String? {
        // For likes, reposts, and replies, we need to fetch the subject post
        if let subjectURI = notification.reasonSubjectURI,
           notification.reason.rawValue != "follow" { // Follows don't have subject content
            
            do {
                // Use getPosts with the AT URI to fetch the post
                let postsResponse = try await clientManager?.account.getPosts([subjectURI])
                
                // Extract text from the first post in the response
                if let firstPost = postsResponse?.posts.first {
                    // Use reflection to extract text from the post record
                    return extractTextFromUnknownType(firstPost.record)
                }
                
                return nil
                
            } catch {
                print("Error fetching subject content: \(error)")
                return nil
            }
        }
        
        // For mentions, the content might be in the notification record itself
        if notification.reason.rawValue == "mention" {
            // Try to extract text from the record
            return extractTextFromUnknownType(notification.record)
        }
        
        return nil
    }
    
    private func extractTextFromUnknownType(_ record: UnknownType) -> String? {
        // Use reflection to safely extract text from various record types
        let mirror = Mirror(reflecting: record)
        
        // Look for text property directly
        for child in mirror.children {
            if child.label == "text",
               let text = child.value as? String {
                return text
            }
        }
        
        // Look for nested record with text
        for child in mirror.children {
            let nestedMirror = child.value
            let innerMirror = Mirror(reflecting: nestedMirror)
            for innerChild in innerMirror.children {
                if innerChild.label == "text",
                   let text = innerChild.value as? String {
                    return text
                }
            }
        }
        
        // Debug: print structure to understand the record format
        print("Record structure:")
        for child in mirror.children {
            print("- \(child.label ?? "unknown"): \(type(of: child.value))")
        }
        
        return nil
    }
    
    private func extractReason(from reason: AppBskyLexicon.Notification.Notification.Reason) -> String {
        switch reason.rawValue {
        case "like": return "liked your post"
        case "reply": return "replied to you"
        case "repost": return "reposted you"
        case "mention": return "mentioned you"
        case "follow": return "followed you"
        case "quote": return "quoted your post"
        default: return reason.rawValue
        }
    }
    
    private func extractAuthor(from author: AppBskyLexicon.Actor.ProfileViewDefinition) -> String {
        if let displayName = author.displayName, !displayName.isEmpty {
            return displayName
        }
        return author.actorHandle
    }
    
    private func extractAuthorDID(from author: AppBskyLexicon.Actor.ProfileViewDefinition) -> String {
        return author.actorDID
    }
    
    private func extractAuthorImageURL(from author: AppBskyLexicon.Actor.ProfileViewDefinition) -> URL? {
        return author.avatarImageURL
    }
}

// MARK: - COLLECTION EXTENSION
private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
