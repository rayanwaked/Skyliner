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
    var secure: Bool = false
    var icon: Image
    var title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
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
        .glassEffect(.regular.tint(.secondary.opacity(0.2)).interactive())
        .contentShape(RoundedRectangle(cornerRadius: 100))
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

