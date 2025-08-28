//
//  Auth2FA.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/21/25.
//

import SwiftUI

// MARK: - 2FA SECTION
extension AuthenticationView {
    func authenticationSection(
        code: Binding<String>,
        onSubmit: @escaping () -> Void) -> some View {
        VStack(alignment: .leading) {
            // MARK: - HEADER
            headerSection
            
            // MARK: - INPUT
            InputFieldComponent(
                icon: Image(systemName: "key.horizontal"),
                title: "Secure code",
                text: code
            )
            .padding(.bottom, Screen.height * 0.02)
            
            HStack {
                // MARK: - SIGN IN
                ButtonComponent(
                    "Submit code",
                    variation: .primary,
                    haptic: .success
                ) {
                    onSubmit()
                }
            }
        }
        .standardCardStyle()
        .transition(.move(edge: .trailing))
        .overlay(skylinerIcon, alignment: .topTrailing)
    }
}
