//
//  Helpers.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - IMPORTS
import SwiftUI
import UIKit

// MARK: - DISMISS KEYBOARD
#if canImport(UIKit)
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct DateHelper {
    static func formattedRelativeDate(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        let absInterval = abs(interval)
        let hour: TimeInterval = 60 * 60
        let day: TimeInterval = 24 * hour
        let days30: TimeInterval = 30 * day

        if absInterval < day {
            // Within 24 hours
            let hours = Int(absInterval / hour)
            return "\(hours)h ago"
        } else if absInterval < days30 {
            // Within 30 days
            let days = Int(absInterval / day)
            return "\(days)d ago"
        } else {
            // Older than 30 days
            let formatter = DateFormatter()
            formatter.dateFormat = "d/M/yy"
            return formatter.string(from: date)
        }
    }
}
