//
//  Modifiers.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
internal import Combine

// MARK: - CARD STYLING
/// A view modifier that applies a standardized card style to any view, including padding, background, and rounded corners.
struct StandardCardModifier: ViewModifier {
    /// Modifies the given content with standard padding, card background, rounded corners, and extra padding.
    func body(content: Content) -> some View {
        content
            .padding(Padding.large)
            .background(.standardBackground)
            .clipShape(RoundedRectangle(cornerRadius: Radius.standard))
            .padding(Padding.standard)
    }
}

extension View {
    /// Applies the app's standard card style to this view using StandardCardModifier.
    func standardCardStyle() -> some View {
        self.modifier(StandardCardModifier())
    }
}

// MARK: - SHADOW OVERLAY
struct ShadowOverlay: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Rectangle()
            .fill(.standardBackground)
            .frame(height: 3)
            .padding(.top, -3)
            .shadow(color: colorScheme == .dark ? .black : .white, radius: Radius.small)
            .shadow(color: colorScheme == .dark ? .black : .white, radius: Radius.small)
            .shadow(color: colorScheme == .dark ? .black : .white.opacity((Opacity.standard)), radius: Radius.small)
            .shadow(color: colorScheme == .dark ? .black : .white, radius: Radius.standard)
            .shadow(
                color: colorScheme == .light ? .white : .clear,
                radius: Radius.standard * 1.25
            )
            .ignoresSafeArea(.container, edges: .top)
            .allowsHitTesting(false)
    }
}

// MARK: - NUMBER FORMATTER
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

// MARK: - FONT SIZE
extension Font {
    static func smaller(
        _ style: TextStyle,
        adjustment: CGFloat = -1
    ) -> Font {
        let baseSize = UIFont.preferredFont(forTextStyle: style.uiTextStyle).pointSize
        return .system(size: baseSize + adjustment)
    }
}

extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
