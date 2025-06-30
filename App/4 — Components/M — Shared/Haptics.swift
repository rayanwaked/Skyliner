//
//  Haptics.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - Imports
import SwiftUI

// MARK: - Haptic Class
final class Haptic {
    static let shared = Haptic()
    private init() {}
    
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Haptic Modifier
struct HapticOnTapModifier: ViewModifier {
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    
    func body(content: Content) -> some View {
        content.onTapGesture {
            Haptic.shared.play(style)
        }
    }
}

// MARK: - Haptic Extension
extension View {
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) -> some View {
        self.modifier(HapticOnTapModifier(style: style))
    }
}
