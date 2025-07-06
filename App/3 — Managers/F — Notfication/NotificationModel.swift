//
//  NotificationModel.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/5/25.
//

import Foundation

/// Represents a notification event from ATProtoKit / Bluesky
public struct NotificationModel: Identifiable, @MainActor Codable, Equatable {
    
    /// The unique identifier for this notification, fulfilling Identifiable protocol
    public var id: String { uri }
    
    /// URI of the notification record itself
    public let uri: String
    
    /// CID (Content Identifier) for the notification record
    public let cid: String
    
    /// The author profile of the notification
    public let author: ProfileView
    
    /// The reason for this notification (e.g., "like", "repost", "follow", "mention")
    public let reason: NotificationReason
    
    /// URI of the subject that triggered the notification (e.g., post, thread)
    public let reasonSubject: String?
    
    /// Arbitrary record content associated with the notification
    /// This holds the actual content of the notification record encoded as CodableValue
    public let record: CodableValue?
    
    /// Optional flags (e.g., whether user has seen it or not)
    public var isRead: Bool
    
    /// Timestamp when the notification was indexed (added to the system)
    public let indexedAt: Date
    
    /// Optional labels associated with the notification
    public let labels: [Label]?
    
    // MARK: - Nested Types
    
    /// Common reasons for ATProto notifications
    public enum NotificationReason: String, Codable {
        case like
        case repost
        case follow
        case mention
        case reply
        case quote
        case starterpackJoined = "starterpack-joined"
        case verified
        case unverified
        case likeViaRepost = "like-via-repost"
        case repostViaRepost = "repost-via-repost"
        case subscribedPost = "subscribed-post"
        case other
    }
    
    /// Minimal profile view representing the author of the notification
    public struct ProfileView: @MainActor Codable, Equatable {
        public let did: String
        public let handle: String
        public let displayName: String?
        public let avatar: URL?
        
        public init(
            did: String,
            handle: String,
            displayName: String? = nil,
            avatar: URL? = nil
        ) {
            self.did = did
            self.handle = handle
            self.displayName = displayName
            self.avatar = avatar
        }
    }
    
    /// Label represents metadata tags associated with notifications
    public struct Label: @MainActor Codable, Equatable {
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
    
    /// CodableValue is a helper to encode/decode arbitrary Codable data within the notification record.
    /// It supports any Encodable/Decodable value by encoding to JSON Data internally.
    public enum CodableValue: @MainActor Codable, Equatable {
        case value(AnyCodable)
        case none
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if container.decodeNil() {
                self = .none
                return
            }
            let anyCodable = try AnyCodable(from: decoder)
            self = .value(anyCodable)
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case .none:
                var container = encoder.singleValueContainer()
                try container.encodeNil()
            case .value(let anyCodable):
                try anyCodable.encode(to: encoder)
            }
        }
        
        public static func == (lhs: CodableValue, rhs: CodableValue) -> Bool {
            switch (lhs, rhs) {
            case (.none, .none):
                return true
            case (.value(let a), .value(let b)):
                return a == b
            default:
                return false
            }
        }
    }
    
    /// Helper wrapper to encode/decode arbitrary Codable values.
    /// This is a simplified version supporting common JSON types.
    public struct AnyCodable: @MainActor Codable, Equatable {
        public let value: Any
        
        public init(_ value: Any) {
            self.value = value
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            if container.decodeNil() {
                self.value = ()
            } else if let bool = try? container.decode(Bool.self) {
                self.value = bool
            } else if let int = try? container.decode(Int.self) {
                self.value = int
            } else if let double = try? container.decode(Double.self) {
                self.value = double
            } else if let string = try? container.decode(String.self) {
                self.value = string
            } else if let array = try? container.decode([AnyCodable].self) {
                self.value = array.map { $0.value }
            } else if let dict = try? container.decode([String: AnyCodable].self) {
                var d: [String: Any] = [:]
                for (key, anyCodableValue) in dict {
                    d[key] = anyCodableValue.value
                }
                self.value = d
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch value {
            case is Void:
                try container.encodeNil()
            case let bool as Bool:
                try container.encode(bool)
            case let int as Int:
                try container.encode(int)
            case let double as Double:
                try container.encode(double)
            case let string as String:
                try container.encode(string)
            case let array as [Any]:
                let encodableArray = array.map { AnyCodable($0) }
                try container.encode(encodableArray)
            case let dict as [String: Any]:
                let encodableDict = Dictionary(uniqueKeysWithValues: dict.map { (key, val) in (key, AnyCodable(val)) })
                try container.encode(encodableDict)
            default:
                let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported type")
                throw EncodingError.invalidValue(value, context)
            }
        }
        
        public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
            switch (lhs.value, rhs.value) {
            case (let l as Int, let r as Int):
                return l == r
            case (let l as String, let r as String):
                return l == r
            case (let l as Double, let r as Double):
                return l == r
            case (let l as Bool, let r as Bool):
                return l == r
            case (let l as [AnyCodable], let r as [AnyCodable]):
                return l == r
            case (let l as [String: AnyCodable], let r as [String: AnyCodable]):
                return l == r
            case (is Void, is Void):
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Initializer
    
    public init(
        uri: String,
        cid: String,
        author: ProfileView,
        reason: NotificationReason,
        reasonSubject: String? = nil,
        record: CodableValue? = nil,
        isRead: Bool = false,
        indexedAt: Date,
        labels: [Label]? = nil
    ) {
        self.uri = uri
        self.cid = cid
        self.author = author
        self.reason = reason
        self.reasonSubject = reasonSubject
        self.record = record
        self.isRead = isRead
        self.indexedAt = indexedAt
        self.labels = labels
    }
    
    // MARK: - Placeholders
    
    public static let placeholders: [NotificationModel] = [
        NotificationModel(
            uri: "did:plc:example1-uri",
            cid: "bafkreiexamplecid1",
            author: ProfileView(
                did: "did:plc:example1-actor",
                handle: "example1handle",
                displayName: "Example One",
                avatar: URL(string: "https://example.com/avatar1.png")
            ),
            reason: .like,
            reasonSubject: "did:plc:example1-subject-uri",
            record: nil,
            isRead: false,
            indexedAt: Date(),
            labels: [Label(value: "important")]
        ),
        NotificationModel(
            uri: "did:plc:example2-uri",
            cid: "bafkreiexamplecid2",
            author: ProfileView(
                did: "did:plc:example2-actor",
                handle: "example2handle",
                displayName: "Example Two",
                avatar: URL(string: "https://example.com/avatar2.png")
            ),
            reason: .mention,
            reasonSubject: "did:plc:example2-subject-uri",
            record: nil,
            isRead: true,
            indexedAt: Date().addingTimeInterval(-3600), // 1 hour ago
            labels: nil
        )
    ]
}

