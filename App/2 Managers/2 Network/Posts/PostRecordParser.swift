//
//  PostRecordParser.swift
//  Skyliner
//
//  Created by Rayan Waked on 3/11/26.
//

import Foundation
import ATProtoKit
import os.log

// MARK: - PARSE RESULT
enum ParseResult<T> {
    case success(T)
    case failure(ParseError)
    
    var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }
}

enum ParseError: Error {
    case noRecordChild
    case invalidRecordType
    case missingField(String)
}

// MARK: - POST RECORD PARSER
enum PostRecordParser {
    /// Extracts the PostRecord from an UnknownType using reflection
    static func extractPostRecord(from record: UnknownType) -> ParseResult<AppBskyLexicon.Feed.PostRecord> {
        let mirror = Mirror(reflecting: record)
        
        guard let recordChild = mirror.children.first(where: { $0.label == "record" }) else {
            AppLogger.posts.debug("No 'record' child found in UnknownType")
            return .failure(.noRecordChild)
        }
        
        guard let postRecord = recordChild.value as? AppBskyLexicon.Feed.PostRecord else {
            AppLogger.posts.debug("Record child is not AppBskyLexicon.Feed.PostRecord")
            return .failure(.invalidRecordType)
        }
        
        return .success(postRecord)
    }
    
    /// Extracts text content from an UnknownType record
    static func extractText(from record: UnknownType) -> String {
        switch extractPostRecord(from: record) {
        case .success(let postRecord):
            return postRecord.text
        case .failure:
            return ""
        }
    }
    
    /// Extracts creation date from an UnknownType record
    static func extractDate(from record: UnknownType) -> Date {
        switch extractPostRecord(from: record) {
        case .success(let postRecord):
            return postRecord.createdAt
        case .failure:
            return Date()
        }
    }
    
    /// Extracts text from various record types (for notifications)
    static func extractTextFromAnyRecord(_ record: UnknownType) -> String? {
        let mirror = Mirror(reflecting: record)
        
        // Look for text property directly
        for child in mirror.children {
            if child.label == "text", let text = child.value as? String {
                return text
            }
        }
        
        // Look for nested record with text
        for child in mirror.children {
            let innerMirror = Mirror(reflecting: child.value)
            for innerChild in innerMirror.children {
                if innerChild.label == "text", let text = innerChild.value as? String {
                    return text
                }
            }
        }
        
        // Try extracting from PostRecord
        if case .success(let postRecord) = extractPostRecord(from: record) {
            return postRecord.text
        }
        
        return nil
    }
}
