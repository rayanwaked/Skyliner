//
//  AuthenticationManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
internal import Combine

extension AuthenticationView {
    @Observable
    class ViewModel {
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
