//
//  ProfileView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import Glur
import PostHog

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
                VStack(alignment: .leading, spacing: 0) {
                    subBanner
                        .padding(.top, currentBannerHeight * 2)
                    
                    description
                    
                    posts
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newValue in
                scrollOffset = newValue
            }
        }
        .background(.standardBackground)
        .ignoresSafeArea(.all)
        .scrollIndicators(.hidden)
        .onAppear {
            if userProfile == nil {
                userProfile = appState.accountManager
            }
            PostHogSDK.shared.capture("Profile View")
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
        .offset(y: parallaxOffset)
        .background(.standardBackground)
    }
    
    private var currentBannerHeight: CGFloat {
        if scrollOffset < 0 {
            return min(bannerHeight + abs(scrollOffset), maxStretch)
        }
        return bannerHeight
    }
    
    private var parallaxOffset: CGFloat {
        if scrollOffset < 0 {
            scrollOffset > 0 ? -scrollOffset * 0.5 : 0
        } else {
            -scrollOffset
        }
    }
}

// MARK: - SUB BANNER
extension ProfileView {
    var subBanner: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: Screen.width * 0.335)
                    .foregroundStyle(Color.standardBackground)
                ProfilePictureComponent(size: .xlarge)
            }
            .padding(.top, -Padding.large * 3)
            
            profileStats
                .padding(.top, -Padding.small)
        }
        .padding(.horizontal, Padding.standard)
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

extension ProfileView {
    var description: some View {
        VStack(alignment: .leading) {
            Text("\(userProfile?.name ?? "")")
                .font(.smaller(.title3))
                .fontWeight(.bold)
            
            Text("@\(userProfile?.handle ?? "")")
                .font(.smaller(.body))
                .fontWeight(.light)
                .padding(.bottom, Padding.tiny / 2)
                .opacity(Opacity.heavy)
            
            Text("\(userProfile?.description ?? "")")
                .font(.smaller(.body))
        }
        .padding(.vertical, Padding.small)
        .padding(.horizontal, Padding.standard)
        .frame(width: Screen.width, alignment: .leading)
    }
}

extension ProfileView {
    @ViewBuilder
    var posts: some View {
        ArrayButtonComponent<String, Text>(
            items: ["Posts"],
            content: { post in
                Text(post)
            },
            action: { _ in })
        
        let posts = appState.postManager.authorData
        if posts.isEmpty {
            Text("No posts yet.")
                .font(.smaller(.headline))
                .opacity(0.6)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, Padding.large)
        } else {
            LazyVStack {
                ForEach(Array(posts.enumerated()), id: \.offset) { index, post in
                    PostCell(
                        postID: post.postID,
                        imageURL: post.imageURL,
                        name: post.name,
                        handle: post.handle,
                        message: post.message
                    )
                }
            }
            .padding(.top, Padding.standard)
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ProfileView()
        .environment(appState)
}

