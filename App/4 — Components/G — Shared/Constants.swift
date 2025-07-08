//
//  Constants.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - IMPORTS
import SwiftUI
import BezelKit

// MARK: - SIZE CONSTANTS
enum SizeConstants {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
}

// MARK: - RADIUS CONSTANTS
enum RadiusConstants {
    static let largeRadius: CGFloat = 22
    static let defaultRadius: CGFloat = 28
    static let smallRadius: CGFloat = 18
    /// Special corner radius utilized BezelKit added with SizeConstant Width to acheive glassEffect to bezel
    static let glassRadius: CGFloat = (.deviceBezel)
}

// MARK: - PADDING CONSTANTS
enum PaddingConstants {
    /// General purpose padding, usually used to pad between componants/views and the stack
    static let largePadding: CGFloat = 20
    static let defaultPadding: CGFloat = 16
    static let smallPadding: CGFloat = 9
    static let tinyPadding: CGFloat = 5
}

// MARK: - COLOR CONSTANTS
enum ColorConstants {
    static let darkOpaque: CGFloat = 0.65
    static let heavyOpaque: CGFloat = 0.5
    static let defaultOpaque: CGFloat = 0.3
    static let lightOpaque: CGFloat = 0.2
    static let softOpaque: CGFloat = 0.1
}

extension ShapeStyle where Self == Color {
    /// The standard background color for cards and surfaces, adapting to the current color scheme
    static var defaultBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 20/255, green: 30/255, blue: 40/255, alpha: 1) : .white
        })
    }
}
