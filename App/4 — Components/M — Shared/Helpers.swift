//
//  Helpers.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - Imports
import SwiftUI
import UIKit

// MARK: - Dismiss Keyboard
#if canImport(UIKit)
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
