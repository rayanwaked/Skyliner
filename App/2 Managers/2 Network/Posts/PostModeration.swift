//
//  PostModeration.swift
//  Skyliner
//
//  Created by Rayan Waked on [Date]
//

import SwiftUI
import ATProtoKit

// MARK: - MODERATION ERROR ENUM
@MainActor
public enum ModerationError: Error, @preconcurrency LocalizedError {
    case noClientManager
    case postNotFound
    case invalidReportReason
    case blockFailed
    case reportFailed
    
    public var errorDescription: String? {
        switch self {
        case .noClientManager:
            return "No client manager available"
        case .postNotFound:
            return "Post not found"
        case .invalidReportReason:
            return "Invalid report reason provided"
        case .blockFailed:
            return "Failed to block user"
        case .reportFailed:
            return "Failed to submit report"
        }
    }
}

// MARK: - REPORT REASON ENUM
public enum ReportReason: String, CaseIterable {
    case spam = "spam"
    case violation = "violation"
    case misleading = "misleading"
    case sexual = "sexual"
    case rude = "rude"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .spam:
            return "Spam"
        case .violation:
            return "Community Guidelines Violation"
        case .misleading:
            return "Misleading Information"
        case .sexual:
            return "Sexual Content"
        case .rude:
            return "Harassment or Abuse"
        case .other:
            return "Other"
        }
    }
    
    var moderationReason: ComAtprotoLexicon.Moderation.ReasonTypeDefinition {
        switch self {
        case .spam:
            return .spam
        case .violation:
            return .violation
        case .misleading:
            return .misleading
        case .sexual:
            return .sexual
        case .rude:
            return .rude
        case .other:
            return .other
        }
    }
}

// MARK: - POST MANAGER EXTENSION
extension PostManager {
    // MARK: - REPORT POST
    public func reportPost(postID: String, reason: ReportReason, additionalContext: String? = nil) async throws {
        guard let clientManager else {
            throw ModerationError.noClientManager
        }
        
        guard let post = findPost(by: postID) else {
            throw ModerationError.postNotFound
        }
        
        await execute("Reporting post") {
            let subject = ComAtprotoLexicon.Moderation.CreateReportRequestBody.SubjectUnion.strongReference(
                .init(recordURI: post.uri, cidHash: post.cid)
            )
            
            _ = try await clientManager.account.createReport(
                with: reason.moderationReason,
                andContextof: additionalContext,
                subject: subject
            )
        }
    }
    
    // MARK: - BLOCK USER
    public func blockUser(authorDID: String) async throws {
        guard let clientManager else {
            throw ModerationError.noClientManager
        }
        
        await execute("Blocking user") {
            _ = try await clientManager.bluesky
                .createBlockRecord(ofType: .actorBlock(actorDID: authorDID))
        }
    }
    
    // MARK: - BLOCK USER BY POST
    public func blockUserFromPost(postID: String) async throws {
        guard let post = findPost(by: postID) else {
            throw ModerationError.postNotFound
        }
        
        try await blockUser(authorDID: post.author.actorDID)
    }
}

// MARK: - SEARCH MANAGER EXTENSION
extension SearchManager {
    // MARK: - REPORT POST
    public func reportPost(postID: String, reason: ReportReason, additionalContext: String? = nil) async throws {
        guard let clientManager else {
            throw ModerationError.noClientManager
        }
        
        guard let post = findPost(by: postID) else {
            throw ModerationError.postNotFound
        }
        
        let subject = ComAtprotoLexicon.Moderation.CreateReportRequestBody.SubjectUnion.strongReference(
            .init(recordURI: post.uri, cidHash: post.cid)
        )
        
        _ = try await clientManager.account.createReport(
            with: reason.moderationReason,
            andContextof: additionalContext,
            subject: subject
        )
    }
    
    // MARK: - BLOCK USER
    public func blockUser(authorDID: String) async throws {
        guard let clientManager else {
            throw ModerationError.noClientManager
        }
        
        _ = try await clientManager.bluesky
            .createBlockRecord(ofType: .actorBlock(actorDID: authorDID))
    }
    
    // MARK: - BLOCK USER BY POST
    public func blockUserFromPost(postID: String) async throws {
        guard let post = findPost(by: postID) else {
            throw ModerationError.postNotFound
        }
        
        try await blockUser(authorDID: post.author.actorDID)
    }
}

// MARK: - USER MANAGER EXTENSION
extension UserManager {
    // MARK: - BLOCK USER
    public func blockUser(authorDID: String) async throws {
        guard let clientManager else {
            throw ModerationError.noClientManager
        }
        
        _ = try await clientManager.bluesky.createBlockRecord(ofType: .actorBlock(actorDID: authorDID))
        logSuccess("User blocked successfully")
    }
    
    // MARK: - REPORT USER
    public func reportUser(authorDID: String, reason: ReportReason, additionalContext: String? = nil) async throws {
        guard let clientManager else {
            throw ModerationError.noClientManager
        }
        
        // Create a strong reference to the user's profile record
        let profileURI = "at://\(authorDID)/app.bsky.actor.profile/self"
        let subject = ComAtprotoLexicon.Moderation.CreateReportRequestBody.SubjectUnion.strongReference(
            .init(recordURI: profileURI, cidHash: "")
        )
        
        _ = try await clientManager.account.createReport(
            with: reason.moderationReason,
            andContextof: additionalContext,
            subject: subject
        )
        
        logSuccess("User reported successfully")
    }
    
    // MARK: - HELPER METHODS
    private func logSuccess(_ message: String) {
        print("✅ \(message)")
    }
}

