//
//  AuthSignin.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - SIGN IN SECTION
extension AuthenticationView {
    func signinSection(
        pdsURL: Binding<String>,
        handle: Binding<String>,
        password: Binding<String>,
        error: String,
        showTwoFactorButton: Bool,
        onSignIn: @escaping () -> Void,
        onGoBack: @escaping () -> Void,
        onGoToTwoFactor: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading) {
            // MARK: - HEADER
            headerSection
            
            // MARK: - INPUT
            InputFieldComponent(
                icon: Image(systemName: "globe"),
                title: "PDS url",
                text: pdsURL
            )
            .keyboardType(.webSearch)
            .autocapitalization(.none)
            
            // MARK: - INPUT
            InputFieldComponent(
                icon: Image(systemName: "at"),
                title: "Account handle",
                text: handle
            )
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            
            InputFieldComponent(
                secure: true,
                icon: Image(systemName: "lock"),
                title: "Account password",
                text: password
            )
            .padding(.bottom, Screen.height * 0.02)
            
            VStack(spacing: Padding.standard) {
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
                    
                    // MARK: - SIGN IN
                    ButtonComponent(
                        "Sign in",
                        variation: .primary,
                        haptic: .success
                    ) {
                        onSignIn()
                    }
                }
                
                // MARK: - TWO FACTOR BUTTON
                if showTwoFactorButton {
                    ButtonComponent(
                        "Enter 2FA Code",
                        variation: .secondary,
                        haptic: .soft
                    ) {
                        onGoToTwoFactor()
                    }
                }
            }
            
            // MARK: - ERROR
            if !error.isEmpty {
                Text(error)
                    .foregroundColor(.red)
                    .font(.smaller(.footnote))
                    .padding(.top, 4)
                    .padding(.leading, 4)
            }
        }
        .standardCardStyle()
        .transition(.move(edge: .trailing))
        .overlay(skylinerIcon, alignment: .topTrailing)
    }
}
