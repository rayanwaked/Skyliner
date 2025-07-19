//
//  ProfileView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import Glur

// MARK: - VIEW
struct ProfileView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @State private var userProfile: AccountManager?
    
    @State private var scrollOffset: CGFloat = 0
    private let bannerHeight: CGFloat = Screen.height * 0.15
    private let maxStretch: CGFloat = Screen.height * 0.25
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            parallaxBanner
                .zIndex(0)
      
            ScrollView {
                Color.clear
                    .frame(height: bannerHeight*2) // Spacer for banner
                
                subBanner
                    .background(Color(.systemBackground))
            }
            .zIndex(1)
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newValue in
                scrollOffset = newValue
            }
        }
        .ignoresSafeArea(.all)
        .scrollIndicators(.hidden)
        .onAppear {
            if userProfile == nil {
                userProfile = appState.accountManager
            }
        }
    }
}

// MARK: - PARALLAX BANNER
extension ProfileView {
    private var parallaxBanner: some View {
        VStack(spacing: 0) {
            Image("PlaceholderBanner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Screen.width, height: currentBannerHeight)
                .clipped()
            
            Image("PlaceholderBanner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: Screen.width, height: currentBannerHeight)
                .clipped()
                .scaleEffect(y: -1)
        }
        .glur(radius: Radius.small, interpolation: 0.9, direction: .down)
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
        .offset(y: parallaxOffset)
    }
    
    private var currentBannerHeight: CGFloat {
        if scrollOffset < 0 {
            return min(bannerHeight + abs(scrollOffset), maxStretch)
        }
        return bannerHeight
    }
    
    private var parallaxOffset: CGFloat {
        scrollOffset > 0 ? -scrollOffset * 0.5 : 0
    }
}

// MARK: - SUB BANNER
extension ProfileView {
    var subBanner: some View {
        HStack {
            ProfilePictureComponent(size: .xlarge)
            profileStats
        }
        .padding(.horizontal, Padding.standard)
        .padding(.top, -Padding.large * 2)
    }
}

// MARK: - PROFILE STATS
extension ProfileView {
    var profileStats: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(userProfile?.followers ?? 0)").bold()
                Text("followers")
            }
            Spacer()
            Divider()
                .frame(maxHeight: Screen.height * 0.03)
            Spacer()
            VStack{
                Text("\(userProfile?.follows ?? 0)").bold()
                Text("following")
            }
            Spacer()
            Divider()
                .frame(maxHeight: Screen.height * 0.03)
            Spacer()
            VStack {
                Text("\(userProfile?.posts ?? 0)").bold()
                Text("posts")
            }
        }
        .font(.smaller(.subheadline))
    }
}

//extension ProfileView {
//    var posts: some View {
//
//    }
//}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ProfileView()
        .environment(appState)
}
