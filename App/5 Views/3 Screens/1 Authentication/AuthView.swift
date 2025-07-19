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
            case welcomeSection, createAccountSection, signinSection
        }
        
        var selectedSection: AuthenticationSections = .welcomeSection
        var createHandle: String = ""
        var createPassword: String = ""
        var createReenteredPassword: String = ""
        var createError: String = ""
        var signinHandle: String = ""
        var signinPassword: String = ""
        var signinError: String = ""
    }
}

// MARK: - VIEW
struct AuthenticationView: View {
    @Environment(AppState.self) private var appState
    @State var isPresentPrivacy = false
    @State var isPresentTerms = false
    @State var isPresentCreate = false
    @State var viewModel = ViewModel()
    
    // MARK: - BODY
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // MARK: - BACKGROUND
            BackgroundDesign(isAnimated: true)
                .ignoresSafeArea(.keyboard)
                .backport.glassEffect(in: RoundedRectangle(
                    cornerRadius: Radius.large
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
                                    try await appState.authManager
                                        .authenticate(
                                            handle: viewModel.signinHandle,
                                            password: viewModel.signinPassword
                                        )
                                    print("🌸 Authentication View: Authenticate function called")
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
        .background(.blue)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    AuthenticationView()
        .environment(appState)
}

