//
//  AuthenticationExtension.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - IMPORT
import SwiftUI

// MARK: - WELCOME SECTION
extension AuthenticationView {
    func welcomeSection(
        onGoSignIn: @escaping () -> Void,
        onGoCreateAccount: @escaping () -> Void) -> some View {
        VStack(alignment: .leading) {
            // MARK: HEADER
            headerSection
            
            // MARK: ACTION
            HStack {
                ButtonComponent(action: {
                    onGoCreateAccount()
                }, label: "Create account", variation: .primary)
                ButtonComponent(action: {
                    onGoSignIn()
                }, label: "Sign in", variation: .secondary)
            }
        }
        .standardCardStyle()
        .overlay(skylinerIcon, alignment: .topTrailing)
        .transition(.move(edge: .leading))
    }
}

// MARK: - HEADER SECTION
extension AuthenticationView {
    var headerSection: some View {
        VStack(alignment: .leading) {
            switch viewModel.selectedSection {
            // MARK: WELCOME
            case .welcomeSection:
                VStack(alignment: .leading) {
                    Text("Skyliner")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("for Bluesky")
                        .font(.headline)
                        .padding(.bottom, PaddingConstants.defaultPadding / 2)
                    Text("Take to the skies with a refined experience for Bluesky")
                        .padding(.bottom, PaddingConstants.defaultPadding * 1.5)
                }
                
            // MARK: CREATE ACCOUNT
            case .createAccountSection:
                VStack(alignment: .leading) {
                    Text("Welcome!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("let's get you started")
                        .font(.headline)
                        .padding(.bottom, PaddingConstants.defaultPadding / 2)
                    Text("We can help you setup a Bluesky account from here")
                        .padding(.bottom, PaddingConstants.defaultPadding * 1.5)
                }
                
            // MARK: SIGN IN
            case .signinSection:
                VStack(alignment: .leading) {
                    Text("Hey!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("welcome back")
                        .font(.headline)
                        .padding(.bottom, PaddingConstants.defaultPadding / 2)
                    Text("There is lots happening, sign in with your Bluesky account to continue")
                        .padding(.bottom, PaddingConstants.defaultPadding * 1.5)
                }
            }
        }
    }
}

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
            
            // MARK: INPUT
            InputFieldComponent(
                icon: Image(systemName: "at"),
                title: "Create new handle",
                text: handle
            )
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            InputFieldComponent(
                secure: true,
                icon: Image(systemName: "lock"),
                title: "Create new password",
                text: password
            )
            InputFieldComponent(
                secure: true,
                icon: Image(systemName: "lock"),
                title: "Re-Enter new password",
                text: reenteredPassword
            )
            .padding(.bottom, SizeConstants.screenHeight * 0.02)
            
            // MARK: BUTTON
            HStack {
                // MARK: - GO BACK
                CompactButtonComponent(
                    action: {
                        dismissKeyboard()
                        onGoBack()
                    },
                    label: Image(
                        systemName: "chevron.backward"
                    ),
                    variation: .secondary,
                    placement: .standard)
                
                // MARK: CREATE ACCOUNT
                ButtonComponent(
                    action: {
                        onCreateAccount()
                    },
                    label: "Create account",
                    variation: .primary)
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
                .padding(PaddingConstants.defaultPadding)
                .padding(PaddingConstants.defaultPadding),
            alignment: .topTrailing
        )
    }
}

// MARK: - SIGN IN SECTION
extension AuthenticationView {
    func signinSection(
        handle: Binding<String>,
        password: Binding<String>,
        error: String,
        onSignIn: @escaping () -> Void,
        onGoBack: @escaping () -> Void) -> some View {
        VStack(alignment: .leading) {
            // MARK: HEADER
            headerSection
            
            // MARK: INPUT
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
            .padding(.bottom, SizeConstants.screenHeight * 0.02)
            
            HStack {
                // MARK: GO BACK
                CompactButtonComponent(
                    action: {
                        dismissKeyboard()
                        onGoBack()
                    },
                    label: Image(
                        systemName: "chevron.backward"
                    ),
                    variation: .secondary,
                    placement: .standard)
                
                // MARK: SIGN IN
                ButtonComponent(action: {
                    onSignIn()
                }, label: "Sign in", variation: .primary)
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
        .overlay(skylinerIcon, alignment: .topTrailing)
    }
}

// MARK: - ICON
extension AuthenticationView {
    @ViewBuilder
    var skylinerIcon: some View {
        Image("SkylinerIcon")
            .resizable()
            .scaledToFit()
            .frame(width: PaddingConstants.defaultPadding * 2.5, height: PaddingConstants.defaultPadding * 2.5)
            .padding(PaddingConstants.defaultPadding * 2)
    }

    // MARK: - DOCUMENT SECTION
    @ViewBuilder
    var documentSection: some View {
        HStack {
            ButtonComponent(action: {
                openURL(URL(string: "https://bsky.social/about/support/privacy-policy")!)
            }, label: "Privacy", variation: .tertiary)
            ButtonComponent(action: {
                openURL(URL(string: "https://bsky.social/about/support/tos")!)
            }, label: "Terms", variation: .tertiary)
        }
    }
}
