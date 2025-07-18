//
//  Haptics.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI

// MARK: - TYPES
public enum HapticType {
    case light, medium, heavy, rigid, soft, success, warning, error
}

// MARK: - FEEDBACK
@MainActor
public func hapticFeedback(_ type: HapticType) {
#if os(iOS)
    switch type {
    case .light:
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    case .medium:
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    case .heavy:
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    case .rigid:
        if #available(iOS 13.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
    case .soft:
        if #available(iOS 13.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        }
    case .success:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    case .warning:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    case .error:
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
#endif
}

// MARK: - EXTENSION
public extension View {
    /// Triggers haptic feedback of the specified type and executes the given action.
    func hapticAction(_ type: HapticType, perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            hapticFeedback(type)
            action()
        }
    }
}
