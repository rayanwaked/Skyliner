//
//  CompactButtonComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/22/25.
//

// MARK: - IMPORT
import SwiftUI

// MARK: - ENUM
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

// MARK: - VIEW
struct CompactButtonComponent: View {
    // MARK: - VARIABLE
    var action: () -> Void
    var label: Image
    var variation: CompactButtonVariation
    var placement: CompactButtonPlacement
    
    // MARK: - BODY
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

// MARK: - STYLE
struct CompactButtonComponentStyle: ButtonStyle {
    // MARK: - VARIABLE
    var variation: CompactButtonVariation = .primary
    var placement: CompactButtonPlacement = .standard
    
    // MARK: - BODY
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
                .padding(
                    placement == .standard ? PaddingConstants.defaultPadding * 0.75 : PaddingConstants
                        .largePadding)
        }
        .glassEffect(.regular.interactive(true))
    }
}

// MARK: - PREVIEW
#Preview {
    // MARK: - STANDARD
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
    
    // MARK: - TAB BAR
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
