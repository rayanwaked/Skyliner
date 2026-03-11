//
//  NotificationsManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/28/25.
//

import SwiftUI
import ATProtoKit
import os.log

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
    private static let maxConcurrentFetches = 10
    private static let batchSize = 25
    
    func loadNotifications() async {
        do {
            guard let fetched = try await appState?.clientManager?.account.listNotifications(
                with: reasons,
                limit: 50,
                isPriority: priority
            ) else {
                AppLogger.notifications.warning("No clientManager available for loading notifications")
                return
            }
            
            rawNotifications = fetched
            
            // Collect all subject URIs that need fetching (batch them)
            let subjectURIs = fetched.notifications.compactMap { notification -> String? in
                guard notification.reason.rawValue != "follow",
                      let uri = notification.reasonSubjectURI else { return nil }
                return uri
            }
            
            // Batch fetch all subject posts at once
            let subjectContents = await batchFetchSubjectContents(uris: subjectURIs)
            
            // Create notification items without additional network calls
            var items: [NotificationItem] = []
            for notification in fetched.notifications {
                let subjectContent: String?
                if notification.reason.rawValue == "mention" {
                    subjectContent = extractTextFromUnknownType(notification.record)
                } else if let uri = notification.reasonSubjectURI {
                    subjectContent = subjectContents[uri]
                } else {
                    subjectContent = nil
                }
                
                let item = NotificationItem(
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
                items.append(item)
            }
            
            notifications = items.sorted { $0.timestamp > $1.timestamp }
            AppLogger.notifications.info("Loaded \(self.notifications.count) notifications")
        } catch {
            AppLogger.notifications.error("Error loading notifications: \(error.localizedDescription)")
        }
    }
    
    // MARK: - BATCH FETCHING
    private func batchFetchSubjectContents(uris: [String]) async -> [String: String] {
        guard !uris.isEmpty else { return [:] }
        
        var results: [String: String] = [:]
        let uniqueURIs = Array(Set(uris)) // Deduplicate URIs
        
        // Process in batches to avoid overwhelming the API
        for batch in uniqueURIs.chunked(into: Self.batchSize) {
            do {
                guard let postsResponse = try await clientManager?.account.getPosts(batch) else {
                    continue
                }
                
                for post in postsResponse.posts {
                    if let text = extractTextFromUnknownType(post.record) {
                        results[post.uri] = text
                    }
                }
            } catch {
                AppLogger.notifications.debug("Error batch fetching posts: \(error.localizedDescription)")
            }
        }
        
        return results
    }
    
    private func extractTextFromUnknownType(_ record: UnknownType) -> String? {
        // Use the centralized parser for consistent extraction
        return PostRecordParser.extractTextFromAnyRecord(record)
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

// MARK: - COLLECTION EXTENSIONS
private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
