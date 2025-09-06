//
//  BannerFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/22/25.
//

import SwiftUI
import NukeUI
import Glur
internal import Combine

// MARK: - FEATURE
struct BannerFeature: View {
    @StateObject var manager: BannerPositionManager
    var bannerURL: URL?
    var isUser: Bool = true
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            LazyImage(url: bannerURL) { result in
                result.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Screen.width, height: manager.currentBannerHeight)
                    .clipped()
            }
            
            LazyImage(url: bannerURL) { result in
                result.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Screen.width, height: manager.currentBannerHeight)
                    .clipped()
                    .scaleEffect(y: -1)
            }
        }
        .glur(radius: Radius.small, offset: 0.45, interpolation: 1.0, direction: .down)
        .clipShape(.rect(
            topLeadingRadius: isUser ? Radius.glass : Radius.glass / 1.6,
            bottomLeadingRadius: Radius.small,
            bottomTrailingRadius: Radius.small,
            topTrailingRadius: isUser ? Radius.glass : Radius.glass / 1.6))
        .backport.glassEffect(in: .rect(
            topLeadingRadius: isUser ? Radius.glass : Radius.glass / 1.6,
            bottomLeadingRadius: Radius.small,
            bottomTrailingRadius: Radius.small,
            topTrailingRadius: isUser ? Radius.glass : Radius.glass / 1.6))
        .offset(y: manager.parallaxOffset)
        .background(.standardBackground)
    }
}

// MARK: - MANAGER
@MainActor
final class BannerPositionManager: ObservableObject {
    @Published var scrollOffset: CGFloat = 0
    let bannerHeight: CGFloat = Screen.width / 3
    var maxStretch: CGFloat { bannerHeight * 1.5 }
    
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

// MARK: - MODIFIER
@available(iOS 18.0, *)
struct ScrollOffsetModifier: ViewModifier {
    let manager: BannerPositionManager
    
    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newValue in
                manager.scrollOffset = newValue
            }
    }
}

// MARK: - VIEW EXTENSION
extension View {
    func scrollOffset(manager: BannerPositionManager) -> some View {
        if #available(iOS 18.0, *) {
            return modifier(ScrollOffsetModifier(manager: manager))
        } else {
            return self
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @StateObject var manager = BannerPositionManager()
    let profileURL = appState.userManager.profilePictureURL
    let bannerURL = appState.userManager.bannerURL ?? URL(string: "https://example.com/banner.png")!
    
    BannerFeature(
        manager: manager,
        bannerURL: bannerURL
    )
}
