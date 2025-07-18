//
//  BannerComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/16/25.
//

import SwiftUI
internal import Combine

// MARK: - VIEW
struct BannerComponent: View {
    // MARK: - PROPERTIES
    @StateObject var bannerManager: BannerFrameManager = .init()
    
    // MARK: - BODY
    var body: some View {
        Image("GradientBackground")
            .resizable()
            .offset(y: bannerManager.verticalOffset)
            .frame(width: bannerManager.bannerWidth, height: bannerManager.bannerHeight)
    }
}

// MARK: - MANAGER
@MainActor
final class BannerFrameManager: ObservableObject {
    @Published var bannerWidth = Screen.width * 1.00
    @Published var bannerHeight = Screen.height * 0.25
    @Published var verticalOffset: CGFloat = 0
    
    @Published var isDragging = false
    
    func handleScrollChange(_ oldValue: Double, _ newValue: Double, isDragging: Bool) {
        self.isDragging = isDragging
        
        if newValue < 0 && isDragging {
            expandBanner(pullDistance: newValue)
        } else if newValue >= 0 {
            offsetBanner(scrollOffset: newValue)
        }
    }
    
    func resetFrame() {
        withAnimation(.easeIn(duration: 0.2)) {
            bannerWidth = Screen.width * 1.00
            bannerHeight = Screen.height * 0.25
        }
    }
    
    private func expandBanner(pullDistance: Double) {
        withAnimation(.smooth(duration: 0.5)) {
            bannerWidth = Screen.width * 1.50
            bannerHeight = (Screen.height * 0.35) - pullDistance
        }
    }
    
    private func offsetBanner(scrollOffset: Double) {
        verticalOffset = -scrollOffset
    }
}

// MARK: - VIEW MODIFIER
struct BannerScrollModifier: ViewModifier {
    let bannerManager: BannerFrameManager
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture()
                    .onChanged { _ in
                        bannerManager.isDragging = true
                    }
                    .onEnded { _ in
                        bannerManager.isDragging = false
                        bannerManager.resetFrame()
                    }
            )
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentOffset.y
            } action: { oldValue, newValue in
                bannerManager.handleScrollChange(oldValue, newValue, isDragging: bannerManager.isDragging)
            }
    }
}

extension View {
    func bannerScrollBehavior(_ manager: BannerFrameManager) -> some View {
        modifier(BannerScrollModifier(bannerManager: manager))
    }
}

#Preview {
    BannerComponent()
}
