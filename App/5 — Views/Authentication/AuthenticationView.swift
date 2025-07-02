//
//  AuthenticationView.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - IMPORT
import SwiftUI


// MARK: - VIEW
struct AuthenticationView: View {
    // MARK: - VARIABLE
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) var openURL
    @State var viewModel = ViewModel()
    
    // MARK: - BODY
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // MARK: BACKGROUND
            BackgroundComponent()
                .ignoresSafeArea(.keyboard)

            // MARK: CONTENT
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

                    // MARK: - SIGN IN
                    case .signinSection:
                        Spacer()
                        signinSection(
                            handle: $viewModel.signinHandle,
                            password: $viewModel.signinPassword,
                            error: viewModel.signinError,
                            onSignIn: {
                                Task {
                                    try await appState.authenticationManager
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
                    }
                }
                .padding(.bottom, -PaddingConstants.defaultPadding)
                .animation(.easeInOut(duration: 0.25), value: viewModel.selectedSection)

                // MARK: DOCUMENT
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

