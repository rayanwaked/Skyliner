//
//  TrendModel.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/1/25.
//

// MARK: - IMPORTS
import Foundation

// MARK: - TREND MODEL
/// Represents a trending topic or hashtag within the AT Protocol context.
public struct TrendModel: @MainActor Codable, Hashable {
    public let topic: String
    public let displayName: String?
    public let description: String?
    public let link: String
    
    public init(topic: String, displayName: String?, description: String?, link: String) {
        self.topic = topic
        self.displayName = displayName
        self.description = description
        self.link = link
    }
}

// MARK: - TREND MODEL PREVIEW PLACEHOLDERS
extension TrendModel {
    /// Example data for previews and prototyping.
    public static let placeholders: [TrendModel] = [
        TrendModel(
            topic: "swiftlang",
            displayName: "Swift Language",
            description: "Discussion and questions about Swift programming.",
            link: "https://bsky.app/tag/swiftlang"
        ),
        TrendModel(
            topic: "atproto",
            displayName: "AT Protocol",
            description: "News and updates on the AT Protocol.",
            link: "https://bsky.app/tag/atproto"
        ),
        TrendModel(
            topic: "WWDC25",
            displayName: "WWDC 2025",
            description: "Everything from Apple's developer conference.",
            link: "https://bsky.app/tag/WWDC25"
        ),
        TrendModel(
            topic: "OpenSource",
            displayName: "Open Source",
            description: "Projects and stories from the open source world.",
            link: "https://bsky.app/tag/OpenSource"
        )
    ]
}
