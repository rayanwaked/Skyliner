//
//  InputFieldComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

// MARK: - Import
import SwiftUI

// MARK: - View
struct InputFieldComponent: View {
    // MARK: - Variable
    var secure: Bool = false
    var icon: Image
    var title: String
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            isFocused = true
        }) {
            inputField
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Extension
extension InputFieldComponent {
    // MARK: - Text Field
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
        .hapticFeedback(.light)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var previewText: String = "Preview"

    // MARK: - Standard
    InputFieldComponent(
        icon: Image(systemName: "at"),
        title: "Title",
        text: $previewText
    )
    
    // MARK: - Secure
    InputFieldComponent(
        secure: true,
        icon: Image(systemName: "lock"),
        title: "Password",
        text: $previewText
    )
}
