//
//  ButtonComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/22/25.
//

import SwiftUI

// MARK: - CONFIGURATION
struct ButtonConfig {
    // MARK: - VARIATION
    enum Variation {
        case primary, secondary, tertiary, quaternary
        
        var backgroundColor: Color {
            switch self {
            case .primary: .blue.opacity(0.8)
            case .secondary: .blue.opacity(Opacity.standard)
            case .tertiary: .clear
            case .quaternary: .standardBackground
            }
        }
        
        var foregroundColor: Color {
            self == .primary ? .white : .blue
        }
        
        var borderWidth: CGFloat {
            self == .tertiary ? 2 : 0
        }
    }
    
    // MARK: - SIZE
    enum Size {
        case compact, inline, standard, tabBar, header, compose
        
        var font: Font {
            switch self {
            case .compact, .standard: .smaller(.subheadline)
            case .inline: .smaller(.caption)
            case .tabBar, .header: .smaller(.title3)
            case .compose: .smaller(.footnote)
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .compact: Padding.standard * 0.85
            case .inline: Padding.standard * 0.70
            case .standard: 0.00
            case .tabBar: Padding.standard * 0.95
            case .header: Padding.standard * 0.50
            case .compose: Padding.standard * 1.10
            }
        }
    }
}

// MARK: - COMPONENT
struct ButtonComponent: View {
    let action: () -> Void
    let variation: ButtonConfig.Variation
    let size: ButtonConfig.Size
    let haptic: HapticType
    let content: AnyView
    
    // Text initializer
    init(
        _ text: String,
        variation: ButtonConfig.Variation = .primary,
        size: ButtonConfig.Size = .standard,
        haptic: HapticType = .medium,
        action: @escaping () -> Void
    ) {
        self.variation = variation
        self.size = size
        self.haptic = haptic
        self.action = action
        self.content = AnyView(Text(text))
    }
    
    // System image initializer
    init(
        systemName: String,
        variation: ButtonConfig.Variation = .primary,
        size: ButtonConfig.Size = .compact,
        haptic: HapticType = .medium,
        action: @escaping () -> Void
    ) {
        self.variation = variation
        self.size = size
        self.haptic = haptic
        self.action = action
        self.content = AnyView(Image(systemName: systemName))
    }
    
    // Custom content initializer
    init<Content: View>(
        variation: ButtonConfig.Variation = .primary,
        size: ButtonConfig.Size = .standard,
        haptic: HapticType = .medium,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.variation = variation
        self.size = size
        self.haptic = haptic
        self.action = action
        self.content = AnyView(content())
    }
    
    // MARK: BODY
    var body: some View {
        Button {
            action()
            hapticFeedback(haptic)
        } label: {
            content
                .font(size.font)
                .fontWeight(.semibold)
                .foregroundStyle(variation.foregroundColor)
                .padding(size.padding)
                .frame(maxWidth: size == .standard ? .infinity : nil)
                .frame(maxHeight: size == .standard ? Screen.height * 0.055 : nil)
                .background {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(variation.backgroundColor)
                        .overlay {
                            if variation.borderWidth > 0 {
                                RoundedRectangle(cornerRadius: 100)
                                    .strokeBorder(Color.blue, lineWidth: variation.borderWidth)
                            }
                        }
                }
        }
        .backport.glassEffect(.interactive(isEnabled: true))
        .fixedSize(horizontal: size != .standard, vertical: false)
    }
}

// MARK: - PREVIEW
#Preview {
    ButtonComponent("Primary", action: { print("Primary") })
    ButtonComponent("Secondary", variation: .secondary) { print("Secondary") }
    ButtonComponent("Tertiary", variation: .tertiary) { print("Tertiary") }
}

