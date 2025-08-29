//
//  Values.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

import SwiftUI
import BezelKit

// MARK: - SCREEN
@MainActor
enum Screen {
    static var width: CGFloat  { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }
}

// MARK: - FRAME
enum Frame {
    struct FrameSize {
        let width: CGFloat
        let height: CGFloat
    }
    
    static var small = {
        FrameSize(width: Screen.width * 0.1,
                  height: Screen.width * 0.1)
    }
    static var standard = {
        FrameSize(width: Screen.width * 0.4,
                  height: Screen.width * 0.4)
    }
    static var large = {
        FrameSize(width: Screen.width * 0.8,
                  height: Screen.width * 0.8)
    }
    static var screen = {
        FrameSize(width: Screen.width,
                  height: Screen.height)
    }
}

extension View {
    func frame(_ size: Frame.FrameSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
}

// MARK: - RADIUS
enum Radius {
    static let large: CGFloat = 22
    static let standard: CGFloat = 28
    static let small: CGFloat = 18
    static let glass: CGFloat = .deviceBezel
}

// MARK: - PADDING
enum Padding {
    static let large: CGFloat = 20
    static let standard: CGFloat = 16
    static let small: CGFloat = 9
    static let tiny: CGFloat = 5
}

// MARK: - OPACITY
enum Opacity {
    static let heavy: CGFloat = 0.65
    static let dark: CGFloat = 0.5
    static let standard: CGFloat = 0.3
    static let light: CGFloat = 0.2
    static let soft: CGFloat = 0.1
}

// MARK: - BACKGROUND
extension ShapeStyle where Self == Color {
    static var standardBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(red: 20/255, green: 30/255, blue: 40/255, alpha: 1) : .white
        })
    }
}
