//
//  CreateAccount.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - CREATE ACCOUNT SECTION
extension AuthenticationView {
    func createAccountSection(
        handle: Binding<String>,
        password: Binding<String>,
        reenteredPassword: Binding<String>,
        error: String,
        onCreateAccount: @escaping () -> Void,
        onGoBack: @escaping () -> Void) -> some View {
            VStack(alignment: .leading) {
                // MARK: HEADER
                headerSection
                
                //            // MARK: INPUT
                //            InputFieldComponent(
                //                icon: Image(systemName: "at"),
                //                title: "Create new handle",
                //                text: handle
                //            )
                //            .keyboardType(.emailAddress)
                //            .autocapitalization(.none)
                //            InputFieldComponent(
                //                secure: true,
                //                icon: Image(systemName: "lock"),
                //                title: "Create new password",
                //                text: password
                //            )
                //            InputFieldComponent(
                //                secure: true,
                //                icon: Image(systemName: "lock"),
                //                title: "Re-Enter new password",
                //                text: reenteredPassword
                //            )
                //            .padding(.bottom, Size.height * 0.02)
                
                // MARK: BUTTON
                HStack {
                    // MARK: - GO BACK
                    ButtonComponent(
                        systemName: "chevron.backward",
                        variation: .secondary,
                        size: .compact,
                        haptic: .soft
                    ) {
                        dismissKeyboard()
                        onGoBack()
                    }
                    
                    // MARK: CREATE ACCOUNT
                    ButtonComponent(
                        "Go to Bluesky",
                        variation: .primary,
                        haptic: .success,
                        action: {
                            openURL(URL(string: "https://bsky.app/")!)
                        })
                }
                
                // MARK: ERROR
                if !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 4)
                        .padding(.leading, 4)
                }
            }
            .standardCardStyle()
            .transition(.move(edge: .trailing))
            .overlay(
                Text("☀️")
                    .font(.largeTitle)
                    .padding(Padding.standard)
                    .padding(Padding.standard),
                alignment: .topTrailing
            )
        }
}
