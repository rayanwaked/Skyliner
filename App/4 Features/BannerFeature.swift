//
//  BannerFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/16/25.
//

import SwiftUI
internal import Combine

// MARK: - VIEW
struct BannerFeature: View {
    // MARK: - PROPERTIES
    @StateObject var manager: BannerFrameManager = .init()
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            Image("PlaceholderBanner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Screen.width, height: manager.bannerHeight)
                .clipped()
        }
        .offset(y: manager.parallaxOffset)
        .frame(width: Screen.width, height: manager.containerHeight)
        .clipped()
    }
}

// MARK: - MANAGER
@MainActor
final class BannerFrameManager: ObservableObject {
    // MARK: - Published Properties
    @Published var bannerHeight: CGFloat
    @Published var parallaxOffset: CGFloat = 0
    @Published var containerHeight: CGFloat
    
    // MARK: - Private Properties
    private let baseBannerHeight = Screen.height * 0.2
    private let maxStretchHeight = Screen.height * 0.3
    
    // MARK: - Init
    init() {
        self.bannerHeight = baseBannerHeight
        self.containerHeight = baseBannerHeight
    }
    
    // MARK: - Public Methods
    func handleScrollChange(offset: CGFloat) {
        if offset < 0 {
            // Pulling down - stretch banner and keep it sticky
            let stretchAmount = abs(offset)
            bannerHeight = min(baseBannerHeight + stretchAmount, maxStretchHeight)
            containerHeight = bannerHeight
            parallaxOffset = 0 // Keep banner at top when stretching
        } else {
            // Scrolling up - parallax effect
            bannerHeight = baseBannerHeight
            containerHeight = baseBannerHeight
            parallaxOffset = -offset * 0.5 // Parallax movement
        }
    }
    
    func resetToBase() {
        withAnimation(.easeOut(duration: 0.3)) {
            bannerHeight = baseBannerHeight
            containerHeight = baseBannerHeight
            parallaxOffset = 0
        }
    }
}

// MARK: - VIEW MODIFIER
struct BannerScrollModifier: ViewModifier {
    let bannerManager: BannerFrameManager
    @State private var isDragging = false
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture()
                    .onChanged { _ in
                        isDragging = true
                    }
                    .onEnded { _ in
                        isDragging = false
                        bannerManager.resetToBase()
                    }
            )
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newValue in
                bannerManager.handleScrollChange(offset: newValue)
            }
    }
}

extension View {
    func bannerScrollBehavior(_ manager: BannerFrameManager) -> some View {
        modifier(BannerScrollModifier(bannerManager: manager))
    }
}
