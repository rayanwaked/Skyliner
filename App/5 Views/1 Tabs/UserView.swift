//
//  UserView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import Glur
import PostHog

// MARK: - VIEW
struct UserView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(Coordinator.self) private var coordinator
    @StateObject var bannerManager = BannerPositionManager()
    @State private var isLoading = false
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            if bannerManager.scrollOffset > Screen.height * 0.3 {
                ShadowOverlay()
                    .zIndex(1)
            }
            
            parallaxBanner
                .zIndex(0)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    subBanner
                        .padding(
                            .top,
                            bannerManager.currentBannerHeight * 2
                        )
                    
                    description
                    
                    posts
                }
                .opacity(isLoading ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.4), value: isLoading)
            }
            .scrollOffset(manager: bannerManager)
            .refreshable {
                Task {
                    await loadUserDataWithAnimation()
                }
            }
        }
        .background(.standardBackground)
        .ignoresSafeArea(.all)
        .scrollIndicators(.never)
        .onAppear {
            Task {
                await loadUserDataWithAnimation()
            }
            PostHogSDK.shared.capture("User View")
        }
    }
    
    // MARK: - LOAD USER DATA WITH ANIMATION
    private func loadUserDataWithAnimation() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            isLoading = true
        }
        
        await appState.userManager.refreshProfile()
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isLoading = false
        }
        
        hapticFeedback(.success)
    }
}

// MARK: - PARALLAX BANNER
extension UserView {
    private var parallaxBanner: some View {
        BannerFeature(
            manager: bannerManager,
            bannerURL: appState.userManager.bannerURL
        )
    }
}

// MARK: - SUB BANNER
extension UserView {
    var subBanner: some View {
        HStack {
            ZStack {
                Circle()
                    .frame(width: Screen.width * 0.32)
                    .foregroundStyle(Color.standardBackground)
                ProfilePictureComponent(size: .xlarge)
                    .scaleEffect(isLoading ? 0.9 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: appState.userManager.profilePictureURL)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
            }
            .padding(.top, -Padding.large * 3)
            
            profileStats
                .padding(.top, -Padding.small)
        }
        .padding(.horizontal, Padding.standard)
    }
}

// MARK: - PROFILE STATS
extension UserView {
    var profileStats: some View {
        HStack {
            Spacer()
            VStack {
                Text("\(appState.userManager.followers ?? 0)")
                    .bold()
                    .contentTransition(.numericText())
                Text("followers")
            }
            Spacer()
            Divider()
                .frame(maxHeight: Screen.height * 0.03)
            Spacer()
            VStack{
                Text("\(appState.userManager.follows ?? 0)")
                    .bold()
                    .contentTransition(.numericText())
                Text("following")
            }
            Spacer()
            Divider()
                .frame(maxHeight: Screen.height * 0.03)
            Spacer()
            VStack {
                Text("\(appState.userManager.posts ?? 0)")
                    .bold()
                    .contentTransition(.numericText())
                Text("posts")
            }
        }
        .font(.smaller(.subheadline))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appState.userManager.followers)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appState.userManager.follows)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appState.userManager.posts)
    }
}

// MARK: - DESCRIPTION
extension UserView {
    var description: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("\(appState.userManager.name ?? "")")
                        .font(.smaller(.title3))
                        .fontWeight(.heavy)
                        .contentTransition(.opacity)
                    
                    Text("@\(appState.userManager.handle ?? "")")
                        .font(.smaller(.body))
                        .fontWeight(.light)
                        .padding(.bottom, Padding.tiny / 2)
                        .opacity(Opacity.heavy)
                        .contentTransition(.opacity)
                }
                .animation(.easeInOut(duration: 0.4), value: appState.userManager.name)
                .animation(.easeInOut(duration: 0.4), value: appState.userManager.handle)
                
                Spacer()
                
                HStack {
                    Spacer()
                    ButtonComponent(
                        "Log out",
                        variation: .primary,
                        size: .profile,
                        haptic: .rigid)
                    {
                        Task {
                            try await appState.authManager.logout()
                        }
                    }
                    .scaleEffect(isLoading ? 0.95 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isLoading)
                }
            }
            
            Text("\(appState.userManager.description ?? "")")
                .font(.smaller(.body))
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: appState.userManager.description)
        }
        .padding(.bottom, Padding.tiny)
        .padding(.horizontal, Padding.standard)
        .frame(width: Screen.width, alignment: .leading)
    }
}

// MARK: - POSTS
extension UserView {
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
        
        if appState.userManager.userPosts.isEmpty {
            Text("No posts yet.")
                .font(.smaller(.headline))
                .opacity(0.6)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, Padding.large)
                .transition(.scale.combined(with: .opacity))
        } else {
            LazyVStack {
                FeedFeature(feed: appState.userManager.userPosts)
            }
            .padding(.top, Padding.standard)
            .padding(.bottom, Padding.large * 4)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @State var coordinator = Coordinator()
    
    UserView()
        .environment(appState)
        .environment(coordinator)
}
