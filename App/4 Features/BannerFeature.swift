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
    var isUser: Bool = true
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            LazyImage(url: manager.bannerURL) { result in
                result.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: Screen.width, height: manager.currentBannerHeight)
                    .clipped()
            }
            
            LazyImage(url: manager.bannerURL) { result in
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
    @Published var bannerURL: URL? = URL(string: "")
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

// MARK: - PREVIEW
#Preview {
    @Previewable @StateObject var manager = BannerPositionManager()
    
    // Due to the nature of the functionality, there is no practical way to simulate the scrolling offset in previews. Therefore, this preview is just visual representation
    BannerFeature(manager: manager)
        .onAppear {
            manager.bannerURL = URL(string: "https://cdn.bsky.app/img/banner/plain/did:plc:fid77rvrx44chjgehhbpduun/bafkreidaqpiitbwjcd4ny3lvkuwetkoz5nrdt2brpdm2cpfkvt4xxbt4zm@jpeg")
        }
}
