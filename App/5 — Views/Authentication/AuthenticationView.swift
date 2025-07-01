//
//  AuthenticationView.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - Import
import SwiftUI

// MARK: - View
struct AuthenticationView: View {
    // MARK: - Variable
    @Environment(AppState.self) private var appState
    @Environment(\.openURL) var openURL
    @StateObject public var viewModel = AuthenticationViewModel()
    
    // MARK: - Body
    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // MARK: Background
            BackgroundComponent()

            // MARK: Content
            VStack {
                VStack {
                    switch viewModel.selectedSection {
                    // MARK: - Welcome
                    case .welcomeSection:
                        Spacer()
                        welcomeSection(
                            onGoSignIn:
                                { viewModel.selectedSection = .signinSection },
                            onGoCreateAccount:
                                { viewModel.selectedSection = .createAccountSection }
                        )

                    // MARK: - Create Acount
                    case .createAccountSection:
                        Spacer()
                        createAccountSection(
                            handle: $viewModel.createHandle,
                            password: $viewModel.createPassword,
                            reenteredPassword: $viewModel.createReenteredPassword,
                            error: viewModel.createError,
                            onCreateAccount: {
                                viewModel.createLogic()
                            },
                            onGoBack: {
                                viewModel.selectedSection = .welcomeSection
                                viewModel.createHandle = ""
                                viewModel.createPassword = ""
                                viewModel.createReenteredPassword = ""
                            }
                        )

                    // MARK: - Sign In
                    case .signinSection:
                        Spacer()
                        signinSection(
                            handle: $viewModel.signinHandle,
                            password: $viewModel.signinPassword,
                            error: viewModel.signinError,
                            onSignIn: {
                                viewModel.signinLogic()
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

                // MARK: Document
                documentSection
                    .standardCardStyle()
                    .ignoresSafeArea(.keyboard)

            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    AuthenticationView()
        .environment(appState)
}

