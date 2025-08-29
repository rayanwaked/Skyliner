//
//  NotificationsManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/28/25.
//

import SwiftUI
import SwiftyBeaver
import ATProtoKit

// MARK: - NOTIFICATION ITEM
struct NotificationItem: Identifiable, Hashable, Equatable {
    let id: String
    let uri: String
    let reason: NotificationReason
    let content: String
    let author: NotificationAuthor
    let timestamp: Date
    let isRead: Bool
    let subjectContent: String?
    let subjectURI: String?
    
    init(
        uri: String,
        reason: NotificationReason,
        content: String,
        author: NotificationAuthor,
        timestamp: Date,
        isRead: Bool,
        subjectContent: String? = nil,
        subjectURI: String? = nil
    ) {
        self.id = uri
        self.uri = uri
        self.reason = reason
        self.content = content
        self.author = author
        self.timestamp = timestamp
        self.isRead = isRead
        self.subjectContent = subjectContent
        self.subjectURI = subjectURI
    }
}

// MARK: - NOTIFICATION AUTHOR
struct NotificationAuthor: Hashable, Equatable {
    let name: String
    let did: String
    let avatarURL: URL?
}

// MARK: - NOTIFICATION REASON
enum NotificationReason: String, CaseIterable, Hashable {
    case like, reply, repost, mention, follow, quote
    
    var displayText: String {
        switch self {
        case .like: return "liked your post"
        case .reply: return "replied to you"
        case .repost: return "reposted you"
        case .mention: return "mentioned you"
        case .follow: return "followed you"
        case .quote: return "quoted your post"
        }
    }
    
    var hasSubjectContent: Bool {
        self != .follow
    }
}

// MARK: - NOTIFICATIONS STATE
struct NotificationsState {
    var items: [NotificationItem] = []
    var isLoading = false
    var error: NotificationError?
}

// MARK: - NOTIFICATIONS MANAGER
@MainActor
@Observable
final class NotificationsManager {
    // MARK: - DEPENDENCIES
    @ObservationIgnored
    var appState: AppState?
    private var clientManager: ClientManager? { appState?.clientManager }
    
    // MARK: - CONFIGURATION
    private var reasons: [AppBskyLexicon.Notification.Notification.Reason]?
    private var isPriority: Bool?
    
    // MARK: - STATE
    private(set) var state = NotificationsState()
    
    // MARK: - COMPUTED PROPERTIES
    var notifications: [NotificationItem] { state.items }
    var isLoading: Bool { state.isLoading }
    var error: NotificationError? { state.error }
    
    // MARK: - INITALIZATION
    init(
        reasons: [AppBskyLexicon.Notification.Notification.Reason]? = nil,
        isPriority: Bool? = nil,
        appState: AppState? = nil
    ) {
        self.reasons = reasons
        self.isPriority = isPriority
        self.appState = appState
    }
}

// MARK: - PUBLIC INTERFACE
extension NotificationsManager {
    func configure(with appState: AppState) {
        self.appState = appState
    }
    
    func loadNotifications() async {
        await withLoadingState {
            try await performLoadNotifications()
        }
    }
    
    func refreshNotifications() async {
        state.items.removeAll()
        await loadNotifications()
    }
}

// MARK: - PRIVATE OPERATIONS
private extension NotificationsManager {
    func performLoadNotifications() async throws {
        guard let clientManager = clientManager else {
            throw NotificationError.clientUnavailable
        }
        
        let response = try await clientManager.account.listNotifications(
            with: reasons,
            limit: 50,
            isPriority: isPriority
        )
        
        let items = await processNotifications(response.notifications)
        state.items = items.sorted { $0.timestamp > $1.timestamp }
    }
    
    func processNotifications(_ notifications: [AppBskyLexicon.Notification.Notification]) async -> [NotificationItem] {
        await withTaskGroup(of: NotificationItem?.self) { group in
            for notification in notifications {
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
            return items
        }
    }
    
    func createNotificationItem(from notification: AppBskyLexicon.Notification.Notification) async -> NotificationItem? {
        guard let reason = NotificationReason(rawValue: notification.reason.rawValue) else {
            log.warning("Unknown notification reason: \(notification.reason.rawValue)")
            return nil
        }
        
        let author = NotificationAuthor(
            name: extractAuthorName(from: notification.author),
            did: notification.author.actorDID,
            avatarURL: notification.author.avatarImageURL
        )
        
        let subjectContent = await extractSubjectContent(from: notification, reason: reason)
        
        return NotificationItem(
            uri: notification.uri,
            reason: reason,
            content: notification.reasonSubjectURI ?? "",
            author: author,
            timestamp: notification.indexedAt,
            isRead: notification.isRead,
            subjectContent: subjectContent,
            subjectURI: notification.reasonSubjectURI
        )
    }
    
    func extractSubjectContent(
        from notification: AppBskyLexicon.Notification.Notification,
        reason: NotificationReason
    ) async -> String? {
        guard reason.hasSubjectContent else { return nil }
        
        if reason == .mention {
            return extractTextFromRecord(notification.record)
        }
        
        guard let subjectURI = notification.reasonSubjectURI else { return nil }
        
        do {
            let postsResponse = try await clientManager?.account.getPosts([subjectURI])
            return postsResponse?.posts.first.flatMap { extractTextFromRecord($0.record) }
        } catch {
            log.error("Failed to fetch subject content: \(error)")
            return nil
        }
    }
    
    func extractTextFromRecord(_ record: UnknownType) -> String? {
        let mirror = Mirror(reflecting: record)
        
        // Direct text property
        if let text = findProperty(named: "text", in: mirror) as? String {
            return text
        }
        
        // Nested text property
        for child in mirror.children {
            let nestedMirror = Mirror(reflecting: child.value)
            if let text = findProperty(named: "text", in: nestedMirror) as? String {
                return text
            }
        }
        
        return nil
    }
    
    func findProperty(named name: String, in mirror: Mirror) -> Any? {
        mirror.children.first { $0.label == name }?.value
    }
    
    func extractAuthorName(from author: AppBskyLexicon.Actor.ProfileViewDefinition) -> String {
        author.displayName?.isEmpty == false ? author.displayName! : author.actorHandle
    }
    
    func withLoadingState<T>(_ operation: () async throws -> T) async -> T? {
        state.isLoading = true
        state.error = nil
        defer { state.isLoading = false }
        
        do {
            return try await operation()
        } catch let error as NotificationError {
            state.error = error
            log.error("Operation failed: \(error)")
            return nil
        } catch {
            let notificationError = NotificationError.loadingFailed(error)
            state.error = notificationError
            log.error("Operation failed: \(notificationError)")
            return nil
        }
    }
}

// MARK: - ERRORS
enum NotificationError: LocalizedError {
    case clientUnavailable
    case loadingFailed(Error)
    case invalidNotification
    
    var errorDescription: String? {
        switch self {
        case .clientUnavailable:
            return "Client manager is not available"
        case .loadingFailed(let error):
            return "Failed to load notifications: \(error.localizedDescription)"
        case .invalidNotification:
            return "Invalid notification format"
        }
    }
}

