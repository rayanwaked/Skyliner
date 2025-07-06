//
//  NotificationManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/5/25.
//

// MARK: - Imports
import SwiftUI
import ATProtoKit

// MARK: - NOTIFICATION MANAGER
@MainActor
@Observable
public class NotificationManager {
    public private(set) var notifications: [NotificationModel] = []
    @ObservationIgnored
    public var clientManager: ClientManager? = nil
}

// MARK: - NOTIFICATION FUNCTIONS
extension NotificationManager {
    /// Fetches notifications from the network using ATProtoKit.
    public func fetchNotifications(limit: Int = 50, cursor: String? = nil) async -> [NotificationModel] {
        guard let configuration = clientManager?.configuration else {
            print("🍄⛔️ ProfileManager: No configuration available")
            return []
        }
        let manager = await ClientManager(configuration: configuration)
        self.clientManager = manager

        do {
            // ATProtoKit may expose the notification API on its blueskyClient, similar to getTimeline/getAuthorFeed in PostManager
            let response = try await manager.protoClient.listNotifications(
                limit: limit,
                cursor: cursor
            )
            let notifications = response.notifications.map { n in
                NotificationModel(
                    uri: n.uri,
                    cid: n.cid,
                    author: NotificationModel.ProfileView(
                        did: n.author.actorDID,
                        handle: n.author.actorHandle,
                        displayName: n.author.displayName,
                        avatar: URL(
                            string: n.author.avatarImageURL?.absoluteString ?? ""
                        )
                    ),
                    reason: NotificationModel
                        .NotificationReason(
                            rawValue: n.reason.rawValue
                        ) ?? .other,
                    reasonSubject: n.reason.rawValue,
                    record: nil,
                    isRead: n.isRead,
                    indexedAt: ISO8601DateFormatter()
                        .date(from: n.indexedAt.ISO8601Format()) ?? Date(),
                    labels: nil
                )
            }
            self.notifications = notifications
            return notifications
        } catch {
            print("Error fetching notifications: \(error)")
            self.notifications = []
            return []
        }
    }
}

