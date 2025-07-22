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
    @StateObject var bannerManager = BannerPositionManager()
    @State private var userProfile: AccountManager?
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            parallaxBanner
                .zIndex(0)
      
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    subBanner
                        .padding(.top, bannerManager.currentBannerHeight * 2)
                    
                    description
                    
                    posts
                }
            }
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newValue in
                bannerManager.scrollOffset = newValue
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
        BannerFeature(manager: bannerManager)
            .onAppear {
                bannerManager.bannerURL = appState.accountManager.bannerURL
            }
    }
}

// MARK: - SUB BANNER
extension ProfileView {
    var subBanner: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: Screen.width * 0.32)
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

// MARK: - DESCRIPTION
extension ProfileView {
    var description: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("\(userProfile?.name ?? "")")
                    .font(.smaller(.title3))
                    .fontWeight(.heavy)
                
                Text("@\(userProfile?.handle ?? "")")
                    .font(.smaller(.body))
                    .fontWeight(.light)
                    .padding(.bottom, Padding.tiny / 2)
                    .opacity(Opacity.heavy)
                
                Text("\(userProfile?.description ?? "")")
                    .font(.smaller(.body))
            }
            
            Spacer()
            
            ButtonComponent(
                "Log out",
                variation: .primary,
                size: .compact,
                haptic: .rigid)
            {
                Task {
                    try await appState.authManager.logout()
                }
            }
            .frame(width: Screen.width * 0.225)
        }
        .padding(.bottom, Padding.tiny)
        .padding(.horizontal, Padding.standard)
        .frame(width: Screen.width, alignment: .leading)
    }
}

// MARK: - POSTS
extension ProfileView {
    @ViewBuilder
    var posts: some View {
        ArrayButtonComponent<String, Text>(
            items: ["Posts"],
            content: { post in
                Text(post)
            },
            action: { _ in })
        .padding(.bottom, Padding.tiny)
        
        Divider()
        
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
            .padding(.bottom, Padding.large * 4)
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ProfileView()
        .environment(appState)
}

