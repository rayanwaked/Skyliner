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
            .padding(PaddingConstants.largePadding)
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

// MARK: - NUMBER FORMAT MODIFIER
extension Int {
    var abbreviated: String {
        let num = Double(self)
        let thousand = 1_000.0
        let million = 1_000_000.0
        let billion = 1_000_000_000.0
        let trillion = 1_000_000_000_000.0

        let formatter: (Double, String) -> String = { value, suffix in
            let str = String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", value)
            return "\(str)\(suffix)"
        }

        switch num {
        case 0..<thousand:
            return String(Int(num))
        case thousand..<million:
            return formatter(num / thousand, "K")
        case million..<billion:
            return formatter(num / million, "M")
        case billion..<trillion:
            return formatter(num / billion, "B")
        default:
            return formatter(num / thousand, "K")
        }
    }
}

// MARK: - Glass Effect Wrapper
extension View {
    /// Applies a basic glass effect if running on iOS 26 or later, otherwise does nothing
    /// - Returns: View with glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect()
        } else {
            self
        }
    }
    
    /// Applies a glass effect with regular style and tint color if running on iOS 26 or later, otherwise does nothing
    /// - Parameter tintColor: The tint color to apply to the glass effect
    /// - Returns: View with glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffect(tint tintColor: Color) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tintColor))
        } else {
            self
        }
    }
    
    /// Applies an interactive glass effect if running on iOS 26 or later, otherwise does nothing
    /// - Returns: View with interactive glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeInteractiveGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.interactive())
        } else {
            self
        }
    }
    
    /// Applies an interactive glass effect with tint color if running on iOS 26 or later, otherwise does nothing
    /// - Parameter tintColor: The tint color to apply to the glass effect
    /// - Returns: View with interactive glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeInteractiveGlassEffect(tint tintColor: Color) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tintColor).interactive())
        } else {
            self
        }
    }
    
    /// Applies a glass effect within a specific region if running on iOS 26 or later, otherwise does nothing
    /// - Parameter region: The region where the effect should be applied
    /// - Returns: View with glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffect<S: Shape>(in region: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: region)
        } else {
            self
        }
    }
    
    /// Applies a glass effect with tint color within a specific region if running on iOS 26 or later, otherwise does nothing
    /// - Parameters:
    ///   - tintColor: The tint color to apply to the glass effect
    ///   - region: The region where the effect should be applied
    /// - Returns: View with glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffect<S: Shape>(tint tintColor: Color, in region: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tintColor), in: region)
        } else {
            self
        }
    }
    
    /// Applies a glass effect with enabled state if running on iOS 26 or later, otherwise does nothing
    /// - Parameter isEnabled: Whether the glass effect should be enabled
    /// - Returns: View with glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffect(isEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(isEnabled: isEnabled)
        } else {
            self
        }
    }
    
    /// Applies a glass effect with tint color and enabled state if running on iOS 26 or later, otherwise does nothing
    /// - Parameters:
    ///   - tintColor: The tint color to apply to the glass effect
    ///   - isEnabled: Whether the glass effect should be enabled
    /// - Returns: View with glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffect(tint tintColor: Color, isEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tintColor), isEnabled: isEnabled)
        } else {
            self
        }
    }
    
    /// Applies a glass effect within a specific region with enabled state if running on iOS 26 or later, otherwise does nothing
    /// - Parameters:
    ///   - region: The region where the effect should be applied
    ///   - isEnabled: Whether the glass effect should be enabled
    /// - Returns: View with glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffect<S: Shape>(in region: S, isEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: region, isEnabled: isEnabled)
        } else {
            self
        }
    }
    
    /// Applies a glass effect with tint color within a specific region with enabled state if running on iOS 26 or later, otherwise does nothing
    /// - Parameters:
    ///   - tintColor: The tint color to apply to the glass effect
    ///   - region: The region where the effect should be applied
    ///   - isEnabled: Whether the glass effect should be enabled
    /// - Returns: View with glass effect applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffect<S: Shape>(tint tintColor: Color, in region: S, isEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(tintColor), in: region, isEnabled: isEnabled)
        } else {
            self
        }
    }
    
    /// Applies a glass effect ID for grouping if running on iOS 26 or later, otherwise does nothing
    /// - Parameters:
    ///   - id: The unique identifier for this glass effect element
    ///   - namespace: The namespace for grouping glass effects together
    /// - Returns: View with glass effect ID applied on iOS 26+, unchanged view on older versions
    @ViewBuilder
    func safeGlassEffectID<ID: Hashable & Sendable>(_ id: ID, in namespace: Namespace.ID) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffectID(id, in: namespace)
        } else {
            self
        }
    }
}

// MARK: - Safe Glass Effect Container
struct SafeGlassEffectContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer {
                content
            }
        } else {
            content
        }
    }
}
