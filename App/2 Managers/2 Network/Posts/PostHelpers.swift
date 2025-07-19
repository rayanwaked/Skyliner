//
//  PostHelpers.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/18/25.
//

import SwiftUI
import ATProtoKit

// MARK: - ERROR HANDLING & LOGGING
extension PostManager {
    func execute(_ operationName: String, operation: () async throws -> Void) async {
        do {
            try await operation()
            logSuccess("\(operationName) completed successfully")
        } catch {
            logError("Failed to \(operationName.lowercased()): \(error.localizedDescription)")
        }
    }
    
    func logSuccess(_ message: String) {
        print("✅ \(message)")
    }
    
    func logError(_ message: String) {
        print("❌ \(message)")
    }
}

// MARK: - EXTRACT MESSAGE
extension PostManager {
    func extractMessage(from record: UnknownType) -> String {
        let mirror = Mirror(reflecting: record)
        
        if let recordChild = mirror.children.first(where: { $0.label == "record" }),
           let postRecord = recordChild.value as? AppBskyLexicon.Feed.PostRecord {
            return postRecord.text
        }
        
        return "Unable to parse content"
    }
    
    func present(_ items: [Any]) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else { return }
        
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = window
        vc.popoverPresentationController?.sourceRect = CGRect(
            x: window.bounds.midX,
            y: window.bounds.midY,
            width: 0,
            height: 0
        )
        window.rootViewController?.present(vc, animated: true)
    }
}
