//
//  Modifiers.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI

// MARK: - MODIFIER
/// A view modifier that applies a standardized card style to any view, including padding, background, and rounded corners.
struct StandardCardModifier: ViewModifier {
    /// Modifies the given content with standard padding, card background, rounded corners, and extra padding.
    func body(content: Content) -> some View {
        content
            .padding(PaddingConstants.defaultPadding)
            .background(.defaultBackground)
            .clipShape(RoundedRectangle(cornerRadius: RadiusConstants.defaultRadius))
            .padding(PaddingConstants.defaultPadding)
    }
}

extension View {
    /// Applies the app's standard card style to this view using StandardCardModifier.
    func standardCardStyle() -> some View {
        self.modifier(StandardCardModifier())
    }
}

// MARK: - PARALAX MODIFIER
/// A view modifier that applies a parallax effect based on a vertical pull offset (e.g., for pull-to-refresh).
struct PullToRefreshParallaxModifier: ViewModifier {
    /// The vertical pull offset (positive for pull down).
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(y: offset * 0.5) // Adjust the multiplier to control parallax strength
    }
}

extension View {
    /// Applies a parallax effect based on a pull-to-refresh offset.
    /// - Parameter offset: The current vertical pull offset.
    func pullToRefreshParallax(offset: CGFloat) -> some View {
        self.modifier(PullToRefreshParallaxModifier(offset: offset))
    }
}
