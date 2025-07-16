//
//  Helpers.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import UIKit
internal import Combine

// MARK: - DISMISS KEYBOARD
#if canImport(UIKit)
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// MARK: - KEYBOARD RESPONDER
final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
            }
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        Publishers.Merge(willShow, willHide)
            .receive(on: RunLoop.main)
            .assign(to: &self.$currentHeight)
    }
}

// MARK: DATE FORMATTER
struct DateHelper {
    static func formattedRelativeDate(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        let absInterval = abs(interval)
        let minute: TimeInterval = 60
        let hour: TimeInterval = 60 * 60
        let day: TimeInterval = 24 * hour
        let days30: TimeInterval = 30 * day
        
        if absInterval < hour {
            // Within 1 hour
            let minutes = Int(absInterval / minute)
            return "\(minutes)m ago"
        } else if absInterval < day {
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

struct LoadMoreHelper: View {
    enum Location {
        case home, explore
    }
    
    var appState: AppState
    var location: Location
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .baselineOffset(Screen.height * -1)
            .onAppear {
                Task {
                    switch location {
                    case .home: await appState.postsManager.loadPosts()
                    case .explore: await appState.searchManager.loadMoreResults()
                    }
                }
            }
    }
}

