//
//  ProfileView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/2/25.
//

// MARK: - IMPORTS
import SwiftUI
import Glur
import BezelKit
import FancyScrollView
import NukeUI
import ATProtoKit

// MARK: - VIEW
struct ProfileView: View {
    // MARK: VARIABLES
    @Environment(AppState.self) private var appState
    @State var authorFeed: [PostModel] = []
    var isUser: Bool {
        appState.profileModel.first?.did == UserDefaults.standard.string(forKey: "userDID")
    }
    var profile: ProfileModel? {
        appState.profileModel.first
    }

    // MARK: BODY
    var body: some View {
        FancyScrollView(
            scrollUpHeaderBehavior: .parallax,
            scrollDownHeaderBehavior: .sticky,
            header: {
                BannerComponent(bannerURL: profile?.banner)
                    .frame(width: SizeConstants.screenWidth)
                    .clipShape(.rect(
                        topLeadingRadius: RadiusConstants.glassRadius,
                        bottomLeadingRadius: RadiusConstants.smallRadius,
                        bottomTrailingRadius: RadiusConstants.smallRadius,
                        topTrailingRadius: RadiusConstants.glassRadius))
                    .safeGlassEffect(in: .rect(
                        topLeadingRadius: RadiusConstants.glassRadius,
                        bottomLeadingRadius: RadiusConstants.smallRadius,
                        bottomTrailingRadius: RadiusConstants.smallRadius,
                        topTrailingRadius: RadiusConstants.glassRadius))}) {
            VStack {
                subBannerSection
                descriptionSection
                postsSection
            }
            .background(.defaultBackground)
        }
        .ignoresSafeArea(.all)
        .scrollIndicators(.hidden)
        .refreshable {
            //
        }
    }
}

// MARK: - PROFILE PICTURE COMPONENT
extension ProfileView {
    var profilePicture: some View {
        LazyImage(url: profile?.avatar) { result in
            result.image?
                .resizable()
                .clipShape(Circle())
                .overlay(Circle().stroke(.defaultBackground, lineWidth: 5))
                .scaledToFit()
        }
        .safeGlassEffect()
        .frame(width: SizeConstants.screenWidth * 0.3, height: SizeConstants.screenWidth * 0.3)
        .padding(.top, SizeConstants.screenHeight * -0.065)
        .shadow(
            color: .defaultBackground.opacity(ColorConstants.darkOpaque),
            radius: 2
        )
    }
}

// MARK: - SUB BANNER SECTION SECTION
extension ProfileView {
    var subBannerSection: some View {
        HStack {
            profilePicture
            
            HStack {
                Spacer()
                VStack {
                    Text("\(profile?.followerCount ?? 0)").bold()
                    Text("followers")
                }
                Spacer()
                Divider()
                    .frame(maxHeight: SizeConstants.screenHeight * 0.03)
                Spacer()
                VStack{
                    Text("\(profile?.followCount ?? 0)").bold()
                    Text("following")
                }
                Spacer()
                Divider()
                    .frame(maxHeight: SizeConstants.screenHeight * 0.03)
                Spacer()
                VStack {
                    Text("\(profile?.postCount ?? 0)").bold()
                    Text("posts")
                }
            }
            .font(.subheadline)
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .padding(.top, -PaddingConstants.tinyPadding)
    }
}

// MARK: - DESCRIPTION SECTION
extension ProfileView {
    var descriptionSection: some View {
        return VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(profile?.displayName ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("@\(profile?.handle ?? "")")
                        .foregroundStyle(.primary.opacity(ColorConstants.darkOpaque))
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                ButtonComponent(
                    action: {
                    },
                    label: (isUser ? "Edit" : "Follow"),
                    variation: .primary)
                .frame(
                    maxWidth: SizeConstants.screenWidth * 0.2,
                    maxHeight: SizeConstants
                        .screenHeight * 0.045)
                
                CompactButtonComponent(
                    action: {},
                    label: Image(systemName: "command"),
                    variation: .secondary,
                    placement: .profile
                )
            }
            .padding(.bottom, PaddingConstants.smallPadding)
            
            Text(profile?.description ?? "")
        }
        .font(.subheadline)
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .frame(width: SizeConstants.screenWidth, alignment: .leading)
    }
}

// MARK: - POSTS SECTION
extension ProfileView {
    var postsSection: some View {
        VStack(spacing: 0) {
            ArrayButtonComponent(
                array: ["Posts"],
                action: {},
                content: { text in
                    Text(text)
                })
                .padding(.top, -PaddingConstants.tinyPadding)
                .padding(.bottom, PaddingConstants.tinyPadding)
                
            SeperatorComponent()
            
            if let configuration = appState.postManager.clientManager?.configuration {
                FeedComponent(feed: authorFeed)
                    .environment(appState)
                    .task(id: configuration.instanceUUID) {
                        let did = UserDefaults.standard.string(forKey: "userDID") ?? ""
                        authorFeed = await appState.postManager.getAuthorFeed(by: did, shouldIncludePins: false)
                    }
            } else {
                ProgressView("Loading your posts...")
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ProfileView()
        .environment(appState)
}

