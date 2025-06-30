//
//  Modifiers.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI

// MARK: - Modifier
/// A view modifier that applies a standardized card style to any view, including padding, background, and rounded corners.
struct StandardCardModifier: ViewModifier {
    /// Modifies the given content with standard padding, card background, rounded corners, and extra padding.
    func body(content: Content) -> some View {
        content
            .padding(PaddingConstants.defaultPadding)
            .background(.defaultBackground)
            .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.defaultRadius))
            .padding(PaddingConstants.defaultPadding)
    }
}

/// An extension to View for applying the standard card style modifier easily.
extension View {
    /// Applies the app's standard card style to this view using StandardCardModifier.
    func standardCardStyle() -> some View {
        self.modifier(StandardCardModifier())
    }
}
