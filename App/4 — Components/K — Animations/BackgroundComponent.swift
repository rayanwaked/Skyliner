//
//  BackgroundComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/22/25.
//

// BackgroundComponent provides a dynamic, animated background with moving clouds for the Skyliner app.

// MARK: - Import
import SwiftUI
internal import Combine

// MARK: - View
/// Main animated background view with gradient and animated clouds.
struct BackgroundComponent: View {
    // Handles all cloud animation state and logic.
    @StateObject private var cloudsAnimator = CloudsAnimator()
    // Track system light/dark mode for adaptive coloring.
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Body
    var body: some View {
        // Use geometry to size/position clouds relative to screen.
        GeometryReader { geo in
            ZStack {
                gradientBackground
                cloud(geo: geo)
            }
            // Start cloud animation on appear.
            .onAppear {
                cloudsAnimator
                    .startAnimating(geoWidth: SizeConstants.screenWidth)
            }
        }
    }
}

// MARK: - Gradient Background
extension BackgroundComponent {
    /// Sky gradient image, fills the background.
    var gradientBackground: some View {
        Image("GradientBackground")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}

private extension BackgroundComponent {
    // MARK: - Cloud View
    /// Displays all cloud images using current animation offsets.
    @ViewBuilder
    private func cloud(geo: GeometryProxy) -> some View {
        ForEach(0..<cloudsAnimator.cloudOffsets.count, id: \.self) { i in
            cloudImage(i: i)
        }
    }

    // MARK: - Cloud Image
    /// Renders a single cloud image with current position, blur, and color.
    @ViewBuilder
    private func cloudImage(i: Int) -> some View {
        Image("CloudIcon")
            .resizable()
            .frame(width: 350 * cloudsAnimator.cloudScales[i], height: 350 * cloudsAnimator.cloudScales[i])
            .blur(radius: 6)
            .offset(x: cloudsAnimator.cloudOffsets[i], y: cloudsAnimator.cloudYPositions[i])
            .shadow(radius: 10)
            .animation(.linear(duration: cloudsAnimator.cloudSpeeds[i]), value: cloudsAnimator.cloudOffsets[i])
            .blur(radius: 10)
            .colorMultiply(
                colorScheme == .light ? .white : .gray.opacity(ColorConstants.defaultOpaque)
            )
    }
}

// MARK: - Clouds Animator ObservableObject
/// Observable object for managing cloud positions, speeds, and animation loops.
@MainActor
class CloudsAnimator: ObservableObject {
    // Horizontal positions for each cloud.
    @Published var cloudOffsets: [CGFloat] = Array(repeating: -300, count: 5)
    
    // Animation durations for each cloud.
    let cloudSpeeds: [Double] = [10, 60, 40, 20, 100]
    // Vertical positions for each cloud.
    let cloudYPositions: [CGFloat] = [-110, -200, -300, -260, -180]
    // Scale factors for each cloud.
    let cloudScales: [CGFloat] = [1.0, 0.7, 1.3, 0.9, 1.15]
    
    // Tracks background width for animation bounds.
    private var geoWidth: CGFloat = 0
    // True if animations are running.
    private var animationActive: Bool = false

    /// Begins cloud animation loops for all clouds across the screen.
    func startAnimating(geoWidth: CGFloat) {
        self.geoWidth = geoWidth
        animationActive = true
        
        for i in cloudOffsets.indices {
            animateCloud(index: i)
        }
    }
    
    /// Animates one cloud from offscreen left to right, then loops.
    private func animateCloud(index: Int) {
        let travelDistance = geoWidth + 400 // Start offscreen, end offscreen
        
        // Animate offset to travelDistance with a linear animation lasting cloudSpeeds[index] seconds
        withAnimation(.linear(duration: cloudSpeeds[index])) {
            cloudOffsets[index] = travelDistance
        }
        
        // After animation completes, reset offset to start position and animate again
        DispatchQueue.main.asyncAfter(deadline: .now() + cloudSpeeds[index]) { [weak self] in
            guard let self = self else { return }
            self.cloudOffsets[index] = -300
            self.animateCloud(index: index)
        }
    }
}

// MARK: - Preview
/// Preview for live canvas and testing.
#Preview {
    BackgroundComponent()
}
