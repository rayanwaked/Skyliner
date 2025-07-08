//
//  InputFieldComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

// MARK: - IMPORT
import SwiftUI

// MARK: - VIEW
struct InputFieldComponent: View {
    // MARK: - VARIABLE
    var searchBar: Bool = false
    var secure: Bool = false
    var icon: Image
    var title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    private var inputOpacity: Color {
        if #available(iOS 26.0, *) {
            return .gray.opacity(ColorConstants.darkOpaque)
        } else {
            return .gray.opacity(ColorConstants.lightOpaque)
        }
    }
    
    // MARK: - BODY
    var body: some View {
        Button(action: {
            isFocused = true
            hapticFeedback(.soft)
        }) {
            inputField
        }
        .buttonStyle(.plain)
    }
}

// MARK: - EXTENSION
extension InputFieldComponent {
    // MARK: - TEXT FIELD
    var inputField: some View {
        HStack {
            icon
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
            if secure {
                SecureField(title, text: $text)
                    .focused($isFocused)
            } else {
                TextField(title, text: $text)
                    .focused($isFocused)
            }
        }
        .padding()
        .frame(maxHeight: searchBar == true ? SizeConstants.screenHeight * 0.057 : SizeConstants.screenHeight * 0.065
        )
        .safeInteractiveGlassEffect()
        .background(inputOpacity)
        .clipShape(RoundedRectangle(cornerRadius: 100))
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var previewText: String = "Preview"

    // MARK: - STANDARD
    InputFieldComponent(
        icon: Image(systemName: "at"),
        title: "Title",
        text: $previewText
    )
    
    // MARK: - SECURE
    InputFieldComponent(
        secure: true,
        icon: Image(systemName: "lock"),
        title: "Password",
        text: $previewText
    )
}
