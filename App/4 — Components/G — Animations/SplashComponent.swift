//
//  SplashComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - VIEW
struct SplashComponent: View {
    // MARK: - VARIABLES
    @State private var didAppear: Bool = false
    @State private var animationProgress: Double = 0
    @State private var opacityChange: Double = 0
    
    // MARK: - VIEW
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            let curveX = -width * 0.55 + width * 1.6 * animationProgress
            let curveY = height * 0.05 - height * 0.25 * pow(animationProgress, 1.7)
            let rotation = -25 * animationProgress
            
            ZStack {
                BackgroundComponent()
                Image("SkylinerIcon")
                    .resizable()
                    .scaledToFit()
                    .opacity(opacityChange)
                    .frame(width: width * 0.45)
                    .offset(x: curveX, y: curveY)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        didAppear = true
                        withAnimation(.linear(duration: 0.95)) {
                            animationProgress = 1
                        }
                        withAnimation(.easeIn(duration: 0.25)) {
                            opacityChange = 1
                        }
                    }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    SplashComponent()
}
