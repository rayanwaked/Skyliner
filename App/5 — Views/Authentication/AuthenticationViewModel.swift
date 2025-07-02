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
        // MARK: - ENUM
        public enum AuthenticationSections {
            case welcomeSection
            case createAccountSection
            case signinSection
        }
        
        // MARK: - UI STATE
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
