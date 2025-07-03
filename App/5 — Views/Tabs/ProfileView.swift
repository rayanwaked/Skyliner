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
import ATProtoKit

// MARK: - VIEW
struct ProfileView: View {
    // MARK: VARIABLES
    @Environment(AppState.self) private var appState
    @State var authorFeed: [PostModel] = []

    // MARK: BODY
    var body: some View {
        FancyScrollView(scrollUpHeaderBehavior: .parallax,
                        scrollDownHeaderBehavior: .offset,
                        header: {
            bannerSection
                .frame(width: SizeConstants.screenWidth)
                .glassEffect(.regular, in: .rect(
                    topLeadingRadius: RadiusConstants.glassRadius,
                    topTrailingRadius: RadiusConstants.glassRadius))}) {
            VStack {
                subBannerSection
                
                descriptionSection
                
                postsSection
            }
        }
        .background(.defaultBackground)
        .scrollIndicators(.hidden)
        .ignoresSafeArea(.container)
    }
}

// MARK: - BANNER SECTION
extension ProfileView {
    var bannerSection: some View {
        @State var profile = appState.profileModel.first
        
        return VStack(spacing: 0) {
            AsyncImage(url: profile?.banner) { result in
                result.image?
                    .resizable()
                    .clipShape(Rectangle())
                    .scaledToFill()
            }
            
            // Reflection
            ZStack(alignment: .top) {
                AsyncImage(url: profile?.banner) { result in
                    result.image?
                        .resizable()
                        .glur(radius: 5, offset: 0.7, direction: .up)
                        .clipShape(Rectangle())
                        .scaledToFill()
                        .scaleEffect(x: 1, y: -1)
                }
            }
        }
    }
}

// MARK: - SUB BANNER SECTION SECTION
extension ProfileView {
    var subBannerSection: some View {
        @State var profile = appState.profileModel.first
        
        return HStack {
            AsyncImage(url: profile?.avatar) { result in
                result.image?
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFit()
            }
            .glassEffect()
            .frame(width: SizeConstants.screenWidth * 0.3, height: SizeConstants.screenWidth * 0.3)
            .padding(.top, SizeConstants.screenHeight * -0.05)
            .shadow(
                color: .defaultBackground.opacity(ColorConstants.darkOpaque),
                radius: 2
            )
            HStack {
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
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
    }
}

// MARK: - DESCRIPTION SECTION
extension ProfileView {
    var descriptionSection: some View {
        @State var profile = appState.profileModel.first
        
        return VStack(alignment: .leading) {
            Text(profile?.displayName ?? "")
                .font(.title2)
                .fontWeight(.bold)
            Text("@\(profile?.handle ?? "")")
                .foregroundStyle(.primary.opacity(ColorConstants.darkOpaque))
                .fontWeight(.medium)
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
        if appState.postManager.configuration != nil {
            AnyView(
                FeedComponent(feed: authorFeed)
                    .task(id: appState.configuration?.instanceUUID) {
                        let did = UserDefaults.standard.string(forKey: "userDID") ?? ""
                        
                        authorFeed = await appState.postManager.getAuthorFeed(by: did, shouldIncludePins: false)
                    }
            )
        } else {
            AnyView(
                ProgressView("Loading your posts...")
            )
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ProfileView()
        .environment(appState)
}
