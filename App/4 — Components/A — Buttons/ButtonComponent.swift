//
//  ButtonComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/22/25.
//

// MARK: - IMPORT
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
    // MARK: - VARIABLE
    var action: () -> Void
    var label: String
    var variation: ButtonVariation
    
    // MARK: - BODY
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
    // MARK: - VARIABLE
    var variation: ButtonVariation = .primary
    
    // MARK: - BODY
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if variation == .primary || variation == .secondary {
                RoundedRectangle(cornerRadius: 100)
                    .foregroundStyle( variation == .primary ? .blue : .blue .opacity(ColorConstants.defaultOpaque)
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

