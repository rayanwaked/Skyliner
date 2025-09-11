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
            case welcomeSection, signinSection, authenticationSection
        }
        
        var selectedSection: AuthenticationSections = .welcomeSection
        
        var signinPDSUrl: String = "https://bsky.social"
        var signinHandle: String = ""
        var signinPassword: String = ""
        var signinError: String = ""
        
        var authenticationCode: String = ""
        var authenticationError: String = ""
        var showTwoFactorButton: Bool = false
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
            onGoSignIn: { viewModel.selectedSection = .signinSection }
        )
        .onAppear {
            PostHogSDK.shared.capture("Welcome View")
        }
    }
}

// MARK: - SIGN IN SECTION
private extension AuthenticationView {
    var signinSectionView: some View {
        signinSection(
            pdsURL: $viewModel.signinPDSUrl,
            handle: $viewModel.signinHandle,
            password: $viewModel.signinPassword,
            error: viewModel.signinError,
            showTwoFactorButton: viewModel.showTwoFactorButton,
            onSignIn: signinAction,
            onGoBack: resetSigninSection,
            onGoToTwoFactor: { viewModel.selectedSection = .authenticationSection }
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
                        pdsURL: viewModel.signinPDSUrl,
                        handle: viewModel.signinHandle,
                        password: viewModel.signinPassword
                    )
                    
                    if appState.authManager.configState == .unauthenticated {
                        viewModel.showTwoFactorButton = true
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
            viewModel.showTwoFactorButton = false
        }
    }
}

// MARK: - AUTHENTICATION SECTION
private extension AuthenticationView {
    var authenticationSectionView: some View {
        authenticationSection(
            code: $viewModel.authenticationCode,
            onGoBack: resetSigninSection,
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
                    try await appState.authManager
                        .submitTwoFactorCode(viewModel.authenticationCode)
                    
                    viewModel.authenticationCode = ""
                    viewModel.signinHandle = ""
                    viewModel.signinPassword = ""
                    viewModel.showTwoFactorButton = false
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
