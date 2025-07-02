//
//  PostModel.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - IMPORTS
import ATProtoKit
import Foundation

// MARK: - POST MODEL
public struct PostModel: Hashable, Identifiable, Equatable, Sendable {
    public func hash(into hasher: inout Hasher) {
      hasher.combine(uri)
    }

    // MARK: - CONSTANTS
      public var id: String { uri + uuid.uuidString }
      private let uuid = UUID()
      public let uri: String
      public let cid: String
      public let indexedAt: Date
      public let indexAtFormatted: String
      public let author: Profile
      public let content: String
      public let replyCount: Int
      public let repostCount: Int
      public let likeCount: Int
      public let likeURI: String?
      public let repostURI: String?
      public let embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?
      public let replyRef: AppBskyLexicon.Feed.PostRecord.ReplyReference?

      public var hasReply: Bool = false

    public init(
      uri: String,
      cid: String,
      indexedAt: Date,
      author: Profile,
      content: String,
      replyCount: Int,
      repostCount: Int,
      likeCount: Int,
      likeURI: String?,
      repostURI: String?,
      embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?,
      replyRef: AppBskyLexicon.Feed.PostRecord.ReplyReference?
    ) {
        self.uri = uri
        self.cid = cid
        self.indexedAt = indexedAt
        self.author = author
        self.content = content
        self.replyCount = replyCount
        self.repostCount = repostCount
        self.likeCount = likeCount
        self.likeURI = likeURI
        self.repostURI = repostURI
        self.embed = embed
        self.indexAtFormatted = indexedAt.description
        self.replyRef = replyRef
      }
  }

// MARK: - FEED VIEW POST DEFINITION EXTENSION
extension AppBskyLexicon.Feed.FeedViewPostDefinition {
    public var postModel: PostModel {
        PostModel (
          uri: post.postModel.uri,
          cid: post.postModel.cid,
          indexedAt: post.indexedAt,
          author: .init(
            did: post.author.actorDID,
            handle: post.author.actorHandle,
            displayName: post.author.displayName,
            avatarImageURL: post.author.avatarImageURL
          ),
          content: post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.text ?? "",
          replyCount: post.replyCount ?? 0,
          repostCount: post.repostCount ?? 0,
          likeCount: post.likeCount ?? 0,
          likeURI: post.viewer?.likeURI,
          repostURI: post.viewer?.repostURI,
          embed: post.embed,
          replyRef: post.record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.reply
        )
    }
}

// MARK: - POST VIEW DEFINITION EXTENSION
extension AppBskyLexicon.Feed.PostViewDefinition {
    public var postModel: PostModel {
        PostModel (
        uri: uri,
        cid: cid,
        indexedAt: indexedAt,
        author: .init(
          did: author.actorDID,
          handle: author.actorHandle,
          displayName: author.displayName,
          avatarImageURL: author.avatarImageURL
        ),
        content: record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.text ?? "",
        replyCount: replyCount ?? 0,
        repostCount: repostCount ?? 0,
        likeCount: likeCount ?? 0,
        likeURI: viewer?.likeURI,
        repostURI: viewer?.repostURI,
        embed: embed,
        replyRef: record.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.reply
        )
    }
}

// MARK: - THREAD VIEW POST DEFINITION EXTENSION
extension AppBskyLexicon.Feed.ThreadViewPostDefinition {

}

// MARK: - VIEW RECORD
extension AppBskyLexicon.Embed.RecordDefinition.ViewRecord {
  public var postModel: PostModel {
      .init(
      uri: uri,
      cid: cid,
      indexedAt: indexedAt,
      author: .init(
        did: author.actorDID,
        handle: author.actorHandle,
        displayName: author.displayName,
        avatarImageURL: author.avatarImageURL
      ),
      content: value.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.text ?? "",
      replyCount: replyCount ?? 0,
      repostCount: repostCount ?? 0,
      likeCount: likeCount ?? 0,
      likeURI: nil,
      repostURI: nil,
      embed: nil,
      replyRef: value.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self)?.reply
    )
  }
}

// MARK: - POST MODEL PREVIEW PLACEHOLDERS
extension PostModel {
    public static let placeholders: [PostModel] = (0..<10).map { i in
        let authors = [
          (did: "catnip1", handle: "cat@bsky", displayName: "Sir Whiskers"),
          (did: "skyblazer2", handle: "skyblazer@bsky", displayName: "Sky Blazer ✈️"),
          (did: "gigglebot3", handle: "gigglebot@bsky", displayName: "GiggleBot 3000 🤖"),
          (did: "rainbow4", handle: "rainbow@bsky", displayName: "Rainbow Sparkle 🌈"),
          (did: "memequeen5", handle: "memequeen@bsky", displayName: "Meme Queen 👑"),
          (did: "owlwise6", handle: "owlwise@bsky", displayName: "Owl Wise 🦉"),
          (did: "pizza7", handle: "pizza@bsky", displayName: "Pizza Lover 🍕"),
          (did: "codingfox8", handle: "codingfox@bsky", displayName: "Coding Fox 🦊"),
          (did: "astro9", handle: "astro@bsky", displayName: "Astro Traveler 🚀"),
          (did: "bananaman10", handle: "bananaman@bsky", displayName: "Banana Man 🍌")
        ]
        
        let funContent = [
          "🚀 Just landed on Blue Sky! What's good?",
          "Meow! 🐾 Looking for treats and followers.",
          "Is it Friday yet? Asking for a friend. 🦥",
          "How many memes is too many memes? Asking for science. 👩‍🔬",
          "Sky's the limit—unless you're a penguin. 🐧",
          "Who else codes in pajamas? 🙋‍♂️",
          "Pizza for breakfast, lunch, AND dinner. 🍕",
          "Just saw a double rainbow! 🌈🌈 Lucky day?",
          "Did someone say cat videos? Send links! 📹",
          "Exploring the universe, one post at a time. 🌌"
        ]
        
        let randomReply = Int.random(in: 0...99)
        let randomRepost = Int.random(in: 0...50)
        let randomLike = Int.random(in: 0...300)
        let author = authors[i % authors.count]
        let content = funContent[i % funContent.count]
        
        return .init(
          uri: UUID().uuidString,
          cid: UUID().uuidString,
          indexedAt: Date(),
          author: .init(
            did: author.did,
            handle: author.handle,
            displayName: author.displayName,
            avatarImageURL: nil),
          content: content,
          replyCount: randomReply,
          repostCount: randomRepost,
          likeCount: randomLike,
          likeURI: nil,
          repostURI: nil,
          embed: nil,
          replyRef: nil)
    }
}

