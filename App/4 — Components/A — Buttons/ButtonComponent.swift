//
//  ButtonComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/22/25.
//

// MARK: - Import
import SwiftUI
import UIKit

// MARK: - Enum
enum ButtonVariation {
    case primary
    case secondary
    case tertiary
}

// MARK: - View
struct ButtonComponent: View {
    // MARK: - Variable
    var action: () -> Void
    var label: String
    var variation: ButtonVariation
    
    // MARK: - Body
    var body: some View {
        Button(label) {
            action()
        }
        .buttonStyle(ButtonComponentStyle(variation: variation))
    }
}

// MARK: - Style
struct ButtonComponentStyle: ButtonStyle {
    // MARK: - Variable
    var variation: ButtonVariation = .primary
    
    // MARK: - Body
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if variation == .primary || variation == .secondary {
                RoundedRectangle(cornerRadius: 100)
                    .foregroundStyle(
                        variation == .primary ? .blue : .blue
                            .opacity(ColorConstants.defaultOpaque)
                    )
                    .frame(maxWidth: .infinity, maxHeight: 50)
            } else {
                RoundedRectangle(cornerRadius: 100)
                    .strokeBorder(Color.blue, lineWidth: 2)
                    .frame(maxWidth: .infinity, maxHeight: 50)
            }
            configuration.label
                .foregroundStyle((variation == .primary) ? .white : .blue)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .glassEffect(.regular.interactive(true))
        .hapticFeedback(.medium)
    }
}

// MARK: - Preview
#Preview {
    ButtonComponent(action: {
        print("Pressed")
    }, label: "Primary", variation: .primary)
    
    ButtonComponent(action: {
        print("Pressed")
    }, label: "Primary", variation: .secondary)
    
    ButtonComponent(action: {
        print("Pressed")
    }, label: "Teriary", variation: .tertiary)
}

