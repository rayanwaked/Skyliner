//
//  PostsManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import ATProtoKit

@Observable
public final class PostsManager {
    @ObservationIgnored
    var appState: AppState? = nil
    
    public private(set) var authorFeed: AppBskyLexicon.Feed.GetTimelineOutput?
    
    //MARK: - Computed Properties
    var postData: [(imageURL: URL?, name: String, handle: String, message: String)] {
        guard let feed = authorFeed?.feed else { return [] }
        
        return feed.compactMap { feedViewPost in
            let post = feedViewPost.post
            let author = post.author
            
            // Extract text from the UnknownType wrapper
            let message: String
            let mirror = Mirror(reflecting: post.record)
            
            if let recordChild = mirror.children.first(where: { $0.label == "record" }),
               let postRecord = recordChild.value as? AppBskyLexicon.Feed.PostRecord {
                message = postRecord.text
            } else {
                message = "Unable to parse content"
            }
            
            return (
                imageURL: author.avatarImageURL,
                name: author.displayName ?? author.actorHandle,
                handle: author.actorHandle,
                message: message
            )
        }
    }
    
    //MARK: - Methods
    func loadPosts() async {
        guard let userDID = appState?.userDID, !userDID.isEmpty else {
            print("❌ No valid userDID available")
            return
        }
        
        do {
            let feedResult = try await appState?.clientManager?.account.getTimeline(using: userDID)
            authorFeed = feedResult
        } catch {
            print(error.localizedDescription)
        }
    }
}
