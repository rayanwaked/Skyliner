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
            // MARK: - BACKGROUND
            BackgroundDesign(isAnimated: true)
                .ignoresSafeArea(.keyboard)
                .backport.glassEffect(in: RoundedRectangle(
                    cornerRadius: Radius.glass
                ))
                .ignoresSafeArea()

            // MARK: - CONTENT
            VStack {
                VStack {
                    switch viewModel.selectedSection {
                    // MARK: - WELCOME
                    case .welcomeSection:
                        Spacer()
                        welcomeSection(
                            onGoSignIn:
                                { viewModel.selectedSection = .signinSection },
                            onGoCreateAccount:
                                { viewModel.selectedSection = .createAccountSection }
                        )
                        .onAppear {
                            PostHogSDK.shared.capture("Welcome View")
                        }

                    // MARK: - CREATE ACOUNT
                    case .createAccountSection:
                        Spacer()
                        createAccountSection(
                            handle: $viewModel.createHandle,
                            password: $viewModel.createPassword,
                            reenteredPassword: $viewModel.createReenteredPassword,
                            error: viewModel.createError,
                            onCreateAccount: {
                                
                            },
                            onGoBack: {
                                viewModel.selectedSection = .welcomeSection
                                viewModel.createHandle = ""
                                viewModel.createPassword = ""
                                viewModel.createReenteredPassword = ""
                            }
                        )
                        .onAppear {
                            PostHogSDK.shared.capture("Create Account View")
                        }

                        // MARK: - SIGN IN
                    case .signinSection:
                        Spacer()
                        signinSection(
                            handle: $viewModel.signinHandle,
                            password: $viewModel.signinPassword,
                            error: viewModel.signinError,
                            onSignIn: {
                                Task {
                                    do {
                                        try await appState.authManager.authenticate(
                                            handle: viewModel.signinHandle,
                                            password: viewModel.signinPassword
                                        )
                                        dismissKeyboard()
                                    } catch {
                                        viewModel.signinError = error.localizedDescription
                                        dismissKeyboard()
                                    }
                                }
                            },
                            onGoBack: {
                                viewModel.selectedSection = .welcomeSection
                                viewModel.signinHandle = ""
                                viewModel.signinPassword = ""
                            }
                        )
                        .onAppear {
                            PostHogSDK.shared.capture("Sign In View")
                        }
                        
                    // MARK: - TWO FACTOR AUTHENTICATION
                    case .authenticationSection:
                        Spacer()
                        authenticationSection(
                            code: $viewModel.authenticationCode,
                            onSubmit: {
                                
                            }
                        )
                        .onAppear {
                            PostHogSDK.shared.capture("Authentication View")
                        }
                    }
                }
                .padding(.bottom, -Padding.standard)
                .animation(.easeInOut(duration: 0.25), value: viewModel.selectedSection)

                // MARK: - DOCUMENT
                documentSection
                    .standardCardStyle()
                    .ignoresSafeArea(.keyboard)

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

