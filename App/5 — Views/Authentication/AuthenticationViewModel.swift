//
//  AuthenticationManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
public import Combine

public class AuthenticationViewModel: ObservableObject {
    // MARK: - Enum
    public enum AuthenticationSections {
        case welcomeSection
        case createAccountSection
        case signinSection
    }
    
    // MARK: - Logic Closure
    public var createLogic: () -> Void
    public var signinLogic: () -> Void
    
    // MARK: - Initialize
    public init(
        createLogic: (() -> Void)? = nil,
        signinLogic: (() -> Void)? = nil
    ) {
        self.createLogic = createLogic ?? { print("🧊 Authentication View Model: Create Logic Called") }
        self.signinLogic = signinLogic ?? { print("🧊 Authentication View Model: Sign In Logic Called") }
    }
    
    // MARK: - UI State
    @Published public var selectedSection: AuthenticationSections = .welcomeSection
    @Published public var createHandle: String = ""
    @Published public var createPassword: String = ""
    @Published public var createReenteredPassword: String = ""
    @Published public var createError: String = ""
    @Published public var signinHandle: String = ""
    @Published public var signinPassword: String = ""
    @Published public var signinError: String = ""
}

