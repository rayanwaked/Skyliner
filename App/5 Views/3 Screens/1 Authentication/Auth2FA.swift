//
//  Auth2FA.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/21/25.
//

import SwiftUI

extension AuthenticationView {
    func authenticationSection(
        code: Binding<String>,
        onGoBack: @escaping () -> Void,
        onSubmit: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading) {
            // MARK: HEADER
            headerSection
            
            // MARK: INPUT
            InputFieldComponent(
                icon: Image(systemName: "key.horizontal"),
                title: "Secure code",
                text: code
            )
            
            .padding(.bottom, Screen.height * 0.02)
            
            HStack {
                // MARK: - GO BACK
                ButtonComponent(
                    systemName: "chevron.backward",
                    variation: .secondary,
                    haptic: .soft
                ) {
                    dismissKeyboard()
                    onGoBack()
                }
                
                // MARK: SIGN IN
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
