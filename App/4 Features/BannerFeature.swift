//
//  BannerFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/22/25.
//

import SwiftUI
import Glur
internal import Combine

struct BannerFeature: View {
    @StateObject var manager: BannerPositionManager
    
    var body: some View {
        VStack(spacing: 0) {
            Image("PlaceholderBanner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Screen.width, height: manager.currentBannerHeight)
                .clipped()
            
            Image("PlaceholderBanner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Screen.width, height: manager.currentBannerHeight)
                .clipped()
                .scaleEffect(y: -1)
        }
        .glur(radius: Radius.small, offset: 0.45, interpolation: 1.0, direction: .down)
        .clipShape(.rect(
            topLeadingRadius: Radius.glass,
            bottomLeadingRadius: Radius.small,
            bottomTrailingRadius: Radius.small,
            topTrailingRadius: Radius.glass))
        .backport.glassEffect(in: .rect(
            topLeadingRadius: Radius.glass,
            bottomLeadingRadius: Radius.small,
            bottomTrailingRadius: Radius.small,
            topTrailingRadius: Radius.glass))
        .offset(y: manager.parallaxOffset)
        .background(.standardBackground)
    }
}

@MainActor
final class BannerPositionManager: ObservableObject {
    @Published var scrollOffset: CGFloat = 0
    let bannerHeight: CGFloat = Screen.height * 0.15
    let maxStretch: CGFloat = Screen.height * 0.25
    
    var currentBannerHeight: CGFloat {
        if scrollOffset < 0 {
            return min(bannerHeight + abs(scrollOffset), maxStretch)
        }
        return bannerHeight
    }
    
    var parallaxOffset: CGFloat {
        if scrollOffset < 0 {
            return scrollOffset > 0 ? -scrollOffset * 0.5 : 0
        } else {
            return -scrollOffset
        }
    }
}

#Preview {
    @Previewable @StateObject var manager = BannerPositionManager()
    BannerFeature(manager: manager)
}
