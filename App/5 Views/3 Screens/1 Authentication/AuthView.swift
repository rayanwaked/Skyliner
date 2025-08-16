//
//  AuthenticationView.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import PostHog

// MARK: - VIEW MODEL
extension AuthenticationView {
    @Observable
    class ViewModel {
        public enum AuthenticationSections {
            case welcomeSection, createAccountSection, signinSection, authenticationSection
        }
        
        var selectedSection: AuthenticationSections = .welcomeSection
        var createHandle: String = ""
        var createPassword: String = ""
        var createReenteredPassword: String = ""
        var createError: String = ""
        var signinHandle: String = ""
        var signinPassword: String = ""
        var signinError: String = ""
        var authenticationCode: String = ""
        var authenticationError: String = ""
    }
}

// MARK: - VIEW
struct AuthenticationView: View {
    @Environment(AppState.self) private var appState
    @State var isPresentPrivacy = false
    @State var isPresentTerms = false
    @State var viewModel = ViewModel()
    
    // MARK: - BODY
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundView
            contentView
        }
    }
}

// MARK: - BACKGROUND
private extension AuthenticationView {
    var backgroundView: some View {
        BackgroundDesign(isAnimated: true)
            .ignoresSafeArea(.keyboard)
            .backport.glassEffect(in: RoundedRectangle(
                cornerRadius: Radius.glass
            ))
            .ignoresSafeArea()
    }
}

// MARK: - CONTENT
private extension AuthenticationView {
    var contentView: some View {
        VStack {
            VStack {
                currentSectionView
            }
            .padding(.bottom, -Padding.standard)
            .animation(.easeInOut(duration: 0.25), value: viewModel.selectedSection)
            
            documentSection
                .standardCardStyle()
                .ignoresSafeArea(.keyboard)
        }
    }
    
    @ViewBuilder
    var currentSectionView: some View {
        switch viewModel.selectedSection {
        case .welcomeSection:
            Spacer()
            welcomeSectionView
        case .createAccountSection:
            Spacer()
            createAccountSectionView
        case .signinSection:
            Spacer()
            signinSectionView
        case .authenticationSection:
            Spacer()
            authenticationSectionView
        }
    }
}

// MARK: - WELCOME SECTION
private extension AuthenticationView {
    var welcomeSectionView: some View {
        welcomeSection(
            onGoSignIn: { viewModel.selectedSection = .signinSection },
            onGoCreateAccount: { viewModel.selectedSection = .createAccountSection }
        )
        .onAppear {
            PostHogSDK.shared.capture("Welcome View")
        }
    }
}

// MARK: - CREATE ACCOUNT SECTION
private extension AuthenticationView {
    var createAccountSectionView: some View {
        createAccountSection(
            handle: $viewModel.createHandle,
            password: $viewModel.createPassword,
            reenteredPassword: $viewModel.createReenteredPassword,
            error: viewModel.createError,
            onCreateAccount: createAccountAction,
            onGoBack: resetCreateAccountSection
        )
        .onAppear {
            PostHogSDK.shared.capture("Create Account View")
        }
    }
    
    var createAccountAction: () -> Void {
        {
            Task {
                //                do {
                //                    let requires2FA = try await appState.authManager.createAccount(
                //                        handle: viewModel.createHandle,
                //                        password: viewModel.createPassword
                //                    )
                //
                //                    if requires2FA {
                //                        viewModel.selectedSection = .authenticationSection
                //                    }
                //                    dismissKeyboard()
                //                } catch {
                //                    viewModel.createError = error.localizedDescription
                //                    dismissKeyboard()
                //                }
            }
        }
    }
    
    var resetCreateAccountSection: () -> Void {
        {
            viewModel.selectedSection = .welcomeSection
            viewModel.createHandle = ""
            viewModel.createPassword = ""
            viewModel.createReenteredPassword = ""
            viewModel.createError = ""
        }
    }
}

// MARK: - SIGN IN SECTION
private extension AuthenticationView {
    var signinSectionView: some View {
        signinSection(
            handle: $viewModel.signinHandle,
            password: $viewModel.signinPassword,
            error: viewModel.signinError,
            onSignIn: signinAction,
            onGoBack: resetSigninSection
        )
        .onAppear {
            PostHogSDK.shared.capture("Sign In View")
        }
    }
    
    var signinAction: () -> Void {
        {
            Task {
                do {
                    try await appState.authManager.startSignIn(
                        handle: viewModel.signinHandle,
                        password: viewModel.signinPassword
                    )
                    
                    if appState.authManager.configState == .unauthorized {
                        viewModel.selectedSection = .authenticationSection
                    }
                    
                    viewModel.authenticationCode = ""
                    viewModel.authenticationError = ""
                    dismissKeyboard()
                } catch {
                    viewModel.signinError = error.localizedDescription
                    dismissKeyboard()
                }
            }
        }
    }
    
    var resetSigninSection: () -> Void {
        {
            viewModel.selectedSection = .welcomeSection
            viewModel.signinHandle = ""
            viewModel.signinPassword = ""
            viewModel.signinError = ""
        }
    }
}

// MARK: - AUTHENTICATION SECTION
private extension AuthenticationView {
    var authenticationSectionView: some View {
        authenticationSection(
            code: $viewModel.authenticationCode,
            onSubmit: authenticationSubmitAction
        )
        .onAppear {
            PostHogSDK.shared.capture("Authentication View")
        }
    }
    
    var authenticationSubmitAction: () -> Void {
        {
            Task {
                do {
                    appState.authManager.submitTwoFactorCode(viewModel.authenticationCode)
                    
                    viewModel.authenticationCode = ""
                    viewModel.signinHandle = ""
                    viewModel.signinPassword = ""
                    viewModel.createHandle = ""
                    viewModel.createPassword = ""
                    viewModel.createReenteredPassword = ""
                    dismissKeyboard()
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    AuthenticationView()
        .environment(appState)
}
