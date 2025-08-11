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
                                Task {
                                    do {
                                        let requires2FA = try await appState.authManager.createAccount(
                                            handle: viewModel.createHandle,
                                            password: viewModel.createPassword
                                        )
                                        
                                        if requires2FA {
                                            viewModel.selectedSection = .authenticationSection
                                        }
                                        dismissKeyboard()
                                    } catch {
                                        viewModel.createError = error.localizedDescription
                                        dismissKeyboard()
                                    }
                                }
                            },
                            onGoBack: {
                                viewModel.selectedSection = .welcomeSection
                                viewModel.createHandle = ""
                                viewModel.createPassword = ""
                                viewModel.createReenteredPassword = ""
                                viewModel.createError = ""
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
                                        try await appState.authManager.startSignIn(
                                            handle: viewModel.signinHandle,
                                            password: viewModel.signinPassword
                                        )
                                        // Move to the 2FA screen; if 2FA isn’t needed, the background task
                                        // will complete and the app will proceed.
                                        viewModel.selectedSection = .authenticationSection
                                        viewModel.authenticationCode = ""
                                        viewModel.authenticationError = ""
                                        dismissKeyboard()
                                    } catch {
                                        // Only show real errors (network, bad creds, etc.)
                                        viewModel.signinError = error.localizedDescription
                                        dismissKeyboard()
                                    }
                                }
                            },
                            onGoBack: {
                                viewModel.selectedSection = .welcomeSection
                                viewModel.signinHandle = ""
                                viewModel.signinPassword = ""
                                viewModel.signinError = ""
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
                                    } catch {
                                        // Handle 2FA verification error
                                        viewModel.authenticationError = error.localizedDescription
                                        dismissKeyboard()
                                    }
                                }
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

