//
//  ButtonComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/22/25.
//

// MARK: - IMPORTS
import SwiftUI
import UIKit

// MARK: - ENUM
enum ButtonVariation {
    case primary
    case secondary
    case tertiary
}

// MARK: - VIEW
struct ButtonComponent: View {
    var action: () -> Void
    var label: String
    var variation: ButtonVariation
    
    var body: some View {
        Button(label) {
            action()
            hapticFeedback(.medium)
        }
        .buttonStyle(ButtonComponentStyle(variation: variation))
    }
}

// MARK: - STYLE
struct ButtonComponentStyle: ButtonStyle {
    var variation: ButtonVariation = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if variation == .primary || variation == .secondary {
                RoundedRectangle(cornerRadius: 100)
                    .foregroundStyle( variation == .primary ? .blue : .blue .opacity(ColorConstants.defaultOpaque)
                    )
            } else {
                RoundedRectangle(cornerRadius: 100)
                    .strokeBorder(Color.blue, lineWidth: 2)
            }
            configuration.label
                .foregroundStyle((variation == .primary) ? .white : .blue)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: SizeConstants.screenHeight
            * 0.055)
        .safeInteractiveGlassEffect()
        
    }
}

// MARK: - PREVIEW
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

