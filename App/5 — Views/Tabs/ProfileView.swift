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
    var profile: ProfileModel? {
        appState.profileModel.first
    }

    // MARK: BODY
    var body: some View {
        FancyScrollView(
            scrollUpHeaderBehavior: .parallax,
            scrollDownHeaderBehavior: .sticky,
            header: {
                bannerSection
                    .frame(width: SizeConstants.screenWidth)
                    .clipShape(.rect(
                        topLeadingRadius: RadiusConstants.glassRadius,
                        bottomLeadingRadius: RadiusConstants.smallRadius,
                        bottomTrailingRadius: RadiusConstants.smallRadius,
                        topTrailingRadius: RadiusConstants.glassRadius))
                    .glassEffect(.regular, in: .rect(
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
        .background(.defaultBackground)
        .ignoresSafeArea(.all)
        .scrollIndicators(.hidden)
        .refreshable {
            //
        }
    }
}

// MARK: - BANNER SECTION
extension ProfileView {
    var bannerSection: some View {
        return VStack(spacing: 0) {
            LazyImage(url: profile?.banner) { result in
                result.image?
                    .resizable()
                    .clipShape(Rectangle())
                    .scaledToFill()
            }
            
            // Reflection
            ZStack(alignment: .top) {
                LazyImage(url: profile?.banner) { result in
                    result.image?
                        .resizable()
                        .glur(radius: 7, offset: 0.7, direction: .up)
                        .clipShape(Rectangle())
                        .scaledToFill()
                        .scaleEffect(x: 1, y: -1)
                }
            }
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
        .glassEffect()
        .frame(width: SizeConstants.screenWidth * 0.3, height: SizeConstants.screenWidth * 0.3)
        .padding(.top, SizeConstants.screenHeight * -0.075)
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
                VStack{
                    Text("\(profile?.followCount ?? 0)").bold()
                    Text("following")
                }
                Spacer()
                VStack {
                    Text("\(profile?.postCount ?? 0)").bold()
                    Text("posts")
                }
            }
            .font(.callout)
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
    }
}

// MARK: - DESCRIPTION SECTION
extension ProfileView {
    var descriptionSection: some View {
        return VStack(alignment: .leading) {
            HStack {
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
                    label: "Edit",
                    variation: .primary)
                .frame(
                    maxWidth: SizeConstants.screenWidth * 0.2,
                    maxHeight: SizeConstants
                        .screenHeight * 0.05)
                
                CompactButtonComponent(
                    action: {},
                    label: Image(systemName: "square.and.arrow.up"),
                    variation: .secondary,
                    placement: .standard
                )
            }
            .padding(.bottom, PaddingConstants.smallPadding)
            
            Text(profile?.description ?? "")
        }
        .font(.callout)
        .padding([.leading, .trailing, .bottom], PaddingConstants.defaultPadding)
        .frame(width: SizeConstants.screenWidth, alignment: .leading)
    }
}

// MARK: - POSTS SECTION
extension ProfileView {
    var postsSection: some View {
        Group {
            HStack {
                Text("Posts")
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.leading, PaddingConstants.defaultPadding)
            SeperatorComponent()
            if let configuration = appState.postManager.configuration {
                FeedComponent(feed: authorFeed)
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

