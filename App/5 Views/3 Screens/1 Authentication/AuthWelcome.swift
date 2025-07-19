//
//  SignIn.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import PostHog

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
//                    ButtonComponent(
//                        "Create account",
//                        variation: .primary,
//                        haptic: .soft
//                    ) {
//                        onGoCreateAccount()
//                    }
                    
                    ButtonComponent(
                        "Sign in",
                        variation: .secondary,
                        haptic: .soft
                    ) {
                        onGoSignIn()
                    }
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
                        .font(.smaller(.title))
                        .fontWeight(.bold)
                    Text("for Bluesky")
                        .font(.smaller(.headline))
                        .padding(.bottom, Padding.standard / 2)
                    Text("Take to the skies with a refined experience for Bluesky")
                        .padding(.bottom, Padding.standard * 1.5)
                }
                
                // MARK: CREATE ACCOUNT
            case .createAccountSection:
                VStack(alignment: .leading) {
                    Text("Welcome")
                        .font(.smaller(.title))
                        .fontWeight(.bold)
                    Text("let's get you started")
                        .font(.smaller(.headline))
                        .padding(.bottom, Padding.standard / 2)
                    Text("You'll first need to create an account on Bluesky")
                        .padding(.bottom, Padding.standard * 1.5)
                }
                
                // MARK: SIGN IN
            case .signinSection:
                VStack(alignment: .leading) {
                    Text("Hey")
                        .font(.smaller(.title))
                        .fontWeight(.bold)
                    Text("welcome back")
                        .font(.smaller(.headline))
                        .padding(.bottom, Padding.standard / 2)
                    Text("There is lots happening, sign in with your Bluesky account to continue")
                        .padding(.bottom, Padding.standard * 1.5)
                }
            }
        }
    }
}


// MARK: - ICON
extension AuthenticationView {
    @ViewBuilder
    var skylinerIcon: some View {
        Image("SkylinerImage")
            .resizable()
            .scaledToFit()
            .frame(width: Padding.standard * 2.5, height: Padding.standard * 2.5)
            .padding(Padding.standard * 2)
    }
    
    // MARK: - DOCUMENT SECTION
    @ViewBuilder
    var documentSection: some View {
        HStack {
            ButtonComponent(
                "Skyliner Privacy",
                variation: .tertiary,
                haptic: .rigid
            ) {
                isPresentPrivacy = true
            }
            .sheet(isPresented: $isPresentPrivacy) {
                WebViewComponent(url: URL(string: "https://skyliner.app")!)
                    .ignoresSafeArea(.all)
                    .onAppear {
                        PostHogSDK.shared.capture("Privacy Policy View")
                    }
            }
            
            ButtonComponent(
                "Bluesky Terms",
                variation: .tertiary,
                haptic: .rigid
            ) {
                isPresentTerms = true
            }
            .sheet(isPresented: $isPresentTerms) {
                WebViewComponent(url: URL(string: "https://bsky.social/about/support/tos")!)
                    .ignoresSafeArea(.all)
                    .onAppear {
                        PostHogSDK.shared.capture("Terms of Service View")
                    }
            }
        }
    }
}
