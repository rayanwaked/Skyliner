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
    case header
    case explore
    case profile
}

// MARK: - ENUM EXTENSIONS
extension CompactButtonVariation {
    @ViewBuilder
    func background(for placement: CompactButtonPlacement) -> some View {
        switch self {
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
    }

    var labelForegroundColor: Color {
        self == .primary ? .white : .blue
    }
}

extension CompactButtonPlacement {
    func font(for placement: CompactButtonPlacement) -> Font {
        switch self {
        case .standard: Font.subheadline
        case .tabBar: Font.title2
        case .header: Font.title3
        case .explore: Font.subheadline
        case .profile: Font.subheadline
        }
    }

    func padding(for placement: CompactButtonPlacement) -> CGFloat {
        switch self {
        case .standard: PaddingConstants.defaultPadding * 0.75
        case .tabBar: PaddingConstants.defaultPadding * 1.15
        case .header: PaddingConstants.defaultPadding * 0.5
        case .explore: PaddingConstants.defaultPadding * 1.0
        case .profile: PaddingConstants.defaultPadding * 0.7
        }
    }
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
            variation.background(for: placement)
            configuration.label
                .foregroundStyle(variation.labelForegroundColor)
                .font(placement.font(for: placement))
                .fontWeight(.semibold)
                .padding(placement.padding(for: placement))
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

