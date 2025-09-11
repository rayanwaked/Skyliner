//
//  AuthenticationView.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import PostHog

// MARK: - VIEW
struct AuthenticationView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    
    // SECTION CONTROLS
    enum Section {
        case welcomeSection, signinSection, authenticationSection
    }
    @State var selectedSection: Section = .welcomeSection
    
    // SIGN IN VALUES
    @State var signinPDSUrl: String = "https://bsky.social"
    @State var signinHandle: String = ""
    @State var signinPassword: String = ""
    @State var signinError: String = ""
    
    // AUTHENTICATION VALUES
    @State var authenticationCode: String = ""
    @State var authenticationError: String = ""
    
    // DOCUMENT CONTROLS
    @State var isPresentPrivacy = false
    @State var isPresentTerms = false
    
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
                switch selectedSection {
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
            .padding(.bottom, -Padding.standard)
            .animation(.easeInOut(duration: 0.25), value: selectedSection)
            
            documentSection
                .standardCardStyle()
                .ignoresSafeArea(.keyboard)
        }
    }
}

// MARK: - WELCOME SECTION
private extension AuthenticationView {
    var welcomeSectionView: some View {
        welcomeSection(
            onGoSignIn: { selectedSection = .signinSection }
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
            pdsURL: $signinPDSUrl,
            handle: $signinHandle,
            password: $signinPassword,
            error: signinError,
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
                        pdsURL: signinPDSUrl,
                        handle: signinHandle,
                        password: signinPassword
                    )
                    
                    if appState.authManager.configState == .unauthenticated {
                        selectedSection = .authenticationSection
                    }
                    
                    authenticationCode = ""
                    authenticationError = ""
                    dismissKeyboard()
                } catch {
                    signinError = error.localizedDescription
                    dismissKeyboard()
                }
            }
        }
    }
    
    var resetSigninSection: () -> Void {
        {
            selectedSection = .welcomeSection
            signinHandle = ""
            signinPassword = ""
            signinError = ""
        }
    }
}

// MARK: - AUTHENTICATION SECTION
private extension AuthenticationView {
    var authenticationSectionView: some View {
        authenticationSection(
            code: $authenticationCode,
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
                        .submitTwoFactorCode(authenticationCode)
                    
                    authenticationCode = ""
                    signinHandle = ""
                    signinPassword = ""
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
