//
//  AuthenticationExtension.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - Import
import SwiftUI

// MARK: - Welcome Section
extension AuthenticationView {
    func welcomeSection(
        onGoSignIn: @escaping () -> Void,
        onGoCreateAccount: @escaping () -> Void) -> some View {
        VStack(alignment: .leading) {
            // MARK: Header
            headerSection
            
            // MARK: Action
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

// MARK: - Header Section
extension AuthenticationView {
    var headerSection: some View {
        VStack(alignment: .leading) {
            switch viewModel.selectedSection {
            // MARK: Welcome
            case .welcomeSection:
                VStack(alignment: .leading) {
                    Text("Skyliner")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("for Bluesky")
                        .font(.headline)
                        .padding(.bottom, PaddingConstants.defaultPadding / 2)
                    Text("Take to the skies with a bespoke experience for Bluesky")
                        .padding(.bottom, PaddingConstants.defaultPadding * 1.5)
                }
                
            // MARK: Create Account
            case .createAccountSection:
                VStack(alignment: .leading) {
                    Text("Welcome!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("happy you're here :)")
                        .font(.headline)
                        .padding(.bottom, PaddingConstants.defaultPadding / 2)
                    Text("Just a quick account setup away from a new kind of social media")
                        .padding(.bottom, PaddingConstants.defaultPadding * 1.5)
                }
                
            // MARK: Sign In
            case .signinSection:
                VStack(alignment: .leading) {
                    Text("Hey!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("welcome back :)")
                        .font(.headline)
                        .padding(.bottom, PaddingConstants.defaultPadding / 2)
                    Text("Are you ready for some cat pictures?")
                        .padding(.bottom, PaddingConstants.defaultPadding * 1.5)
                }
            }
        }
    }
}

// MARK: - Create Account Section
extension AuthenticationView {
    func createAccountSection(
        handle: Binding<String>,
        password: Binding<String>,
        reenteredPassword: Binding<String>,
        error: String,
        onCreateAccount: @escaping () -> Void,
        onGoBack: @escaping () -> Void) -> some View {
        VStack(alignment: .leading) {
            // MARK: Header
            headerSection
            
            // MARK: Input
            InputFieldComponent(
                icon: Image(systemName: "at"),
                title: "Create new handle",
                text: handle
            )
            .keyboardType(.emailAddress)
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
            
            // MARK: Button
            HStack {
                // MARK: - Go Back
                CompactButtonComponent(
                    action: {
                        onGoBack()
                    },
                    label: Image(
                        systemName: "chevron.backward"
                    ),
                    variation: .secondary,
                    placement: .standard)
                
                // MARK: Create Account
                ButtonComponent(
                    action: {
                        onCreateAccount()
                    },
                    label: "Create account",
                    variation: .primary)
            }
            
            // MARK: Error
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

// MARK: - Sign In Section
extension AuthenticationView {
    func signinSection(
        handle: Binding<String>,
        password: Binding<String>,
        error: String,
        onSignIn: @escaping () -> Void,
        onGoBack: @escaping () -> Void) -> some View {
        VStack(alignment: .leading) {
            // MARK: Header
            headerSection
            
            // MARK: Input
            InputFieldComponent(
                icon: Image(systemName: "at"),
                title: "Account handle",
                text: handle
            )
            .keyboardType(.emailAddress)
            InputFieldComponent(
                secure: true,
                icon: Image(systemName: "lock"),
                title: "Account password",
                text: password
            )
            .padding(.bottom, SizeConstants.screenHeight * 0.02)
            
            HStack {
                // MARK: Go back
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
                
                // MARK: Sign In
                ButtonComponent(action: {
                    onSignIn()
                }, label: "Sign in", variation: .primary)
            }
            
            // MARK: Error
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

// MARK: - Icon
extension AuthenticationView {
    @ViewBuilder
    var skylinerIcon: some View {
        Image("SkylinerIcon")
            .resizable()
            .scaledToFit()
            .frame(width: PaddingConstants.defaultPadding * 2.5, height: PaddingConstants.defaultPadding * 2.5)
            .padding(PaddingConstants.defaultPadding * 2)
    }

    // MARK: - Document Section
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
