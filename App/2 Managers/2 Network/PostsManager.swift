//
//  PostsManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit

@MainActor
@Observable
public final class PostsManager {
    // MARK: - Properties
    @ObservationIgnored
    var appState: AppState?
    public private(set) var extendedFeed: [AppBskyLexicon.Feed.GetTimelineOutput] = []
    public private(set) var authorFeed: AppBskyLexicon.Feed.GetTimelineOutput?
    private var currentCursor: String?
    
    // MARK: - Computed Properties
    var postData: [(imageURL: URL?, name: String, handle: String, message: String)] {
        extendedFeed.flatMap(\.feed).compactMap { feed in
            let author = feed.post.author
            let message = extractMessage(from: feed.post.record)
            
            return (
                imageURL: author.avatarImageURL,
                name: author.displayName ?? author.actorHandle,
                handle: author.actorHandle,
                message: message
            )
        }
    }
    
    // MARK: - Methods
    func loadPosts() async {
        guard let userDID = appState?.userDID, !userDID.isEmpty else {
            print("❌ No valid userDID available")
            return
        }
        
        do {
            let feedResult = try await appState?.clientManager?.account.getTimeline(using: userDID, cursor: currentCursor)
            
            if let feedResult {
                currentCursor = feedResult.cursor
                extendedFeed.append(feedResult)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func extractMessage(from record: UnknownType) -> String {
        let mirror = Mirror(reflecting: record)
        
        if let recordChild = mirror.children.first(where: { $0.label == "record" }),
           let postRecord = recordChild.value as? AppBskyLexicon.Feed.PostRecord {
            return postRecord.text
        }
        
        return "Unable to parse content"
    }
}
