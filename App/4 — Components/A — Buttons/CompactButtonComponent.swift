//
//  CompactButtonComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/22/25.
//

// MARK: - Import
import SwiftUI

// MARK: - Enum
enum CompactButtonVariation {
    case primary
    case secondary
    case tertiary
    case quaternary
}

enum CompactButtonPlacement {
    case standard
    case tabBar
}

// MARK: - View
struct CompactButtonComponent: View {
    // MARK: - Variable
    var action: () -> Void
    var label: Image
    var variation: CompactButtonVariation
    var placement: CompactButtonPlacement
    
    // MARK: - Body
    var body: some View {
        Button() {
            action()
            hapticFeedback(.medium)
        } label: {
            label
        }
        .buttonStyle(CompactButtonComponentStyle(variation: variation, placement: placement))
        .fixedSize()
    }
}

// MARK: - Style
struct CompactButtonComponentStyle: ButtonStyle {
    // MARK: - Variable
    var variation: CompactButtonVariation = .primary
    var placement: CompactButtonPlacement = .standard
    
    // MARK: - Body
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            switch variation {
            case .primary:
                RoundedRectangle(cornerRadius: 100)
                    .foregroundStyle(.blue)
            case .secondary:
                RoundedRectangle(cornerRadius: 100)
                    .foregroundStyle(.blue.opacity(ColorConstants.defaultOpaque))
            case .tertiary:
                RoundedRectangle(cornerRadius: 100)
                    .strokeBorder(Color.blue, lineWidth: 2)
            case .quaternary:
                RoundedRectangle(cornerRadius: 100)
                    .foregroundStyle(.defaultBackground)
            }
            configuration.label
                .foregroundStyle((variation == .primary) ? .white : .blue)
                .font(placement == .standard ? .subheadline : .title2)
                .fontWeight(.semibold)
                .padding(PaddingConstants.defaultPadding * 0.75)
        }
        .glassEffect(.regular.interactive(true))
    }
}

// MARK: - Preview
#Preview {
    // MARK: - Standard
    CompactButtonComponent(
        action: {
            print("Pressed")
        }, label: Image(systemName: "chevron.right"), variation: .primary, placement: .standard)
    
    CompactButtonComponent(action: {
        print("Pressed")
    }, label: Image(systemName: "chevron.right"), variation: .secondary, placement: .standard)
    
    CompactButtonComponent(
        action: {
            print("Pressed")
        }, label: Image(systemName: "chevron.right"), variation: .tertiary, placement: .standard)
    CompactButtonComponent(
        action: {
            print("Pressed")
        }, label: Image(systemName: "chevron.right"), variation: .quaternary, placement: .standard)
    
    // MARK: - Tab Bar
    CompactButtonComponent(
        action: {
            print("Pressed")
        }, label: Image(systemName: "chevron.right"), variation: .primary, placement: .tabBar)
    
    CompactButtonComponent(action: {
        print("Pressed")
    }, label: Image(systemName: "chevron.right"), variation: .secondary, placement: .tabBar)
    
    CompactButtonComponent(
        action: {
            print("Pressed")
        }, label: Image(systemName: "chevron.right"), variation: .tertiary, placement: .tabBar)
    
    CompactButtonComponent(
        action: {
            print("Pressed")
        }, label: Image(systemName: "chevron.right"), variation: .quaternary, placement: .tabBar)
}

