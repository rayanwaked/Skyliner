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
import ATProtoKit

// MARK: - VIEW
struct ProfileView: View {
    // MARK: VARIABLES
    @Environment(AppState.self) private var appState
    @State var authorFeed: [PostModel] = []

    // MARK: BODY
    var body: some View {
        ScrollView {
            bannerSection
            
            pictureSection
            
            detailsSection
            
            profileSection
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
            .frame(width: SizeConstants.screenWidth * 1, height: SizeConstants.screenHeight * 0.2)
            
            // Reflection
            ZStack(alignment: .top) {
                AsyncImage(url: profile?.banner) { result in
                    result.image?
                        .resizable()
                        .clipShape(Rectangle())
                        .scaledToFill()
                        .scaleEffect(x: 1, y: -1)
                }
            }
            .frame(height: SizeConstants.screenHeight * 0.1, alignment: .top)
        }
        .glur(radius: 5, interpolation: 1.0, direction: .down)
        .glassEffect(.regular, in: .rect(cornerRadius: LayoutConstants.smallRadius)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: LayoutConstants.glassRadius)
        )
    }
}

// MARK: - PICTURE SECTION
extension ProfileView {
    var pictureSection: some View {
        @State var profile = appState.profileModel.first
        
        return AsyncImage(url: profile?.avatar) { result in
            result.image?
                .resizable()
                .clipShape(Circle())
                .scaledToFit()
        }
        .glassEffect()
        .frame(width: SizeConstants.screenWidth * 0.3, height: SizeConstants.screenWidth * 0.3)
        .padding(.top, SizeConstants.screenHeight * -0.12)
        .shadow(
            color: .defaultBackground.opacity(ColorConstants.darkOpaque),
            radius: 2
        )
    }
}

// MARK: - DETAILS SECTION
extension ProfileView {
    var detailsSection: some View {
        @State var profile = appState.profileModel.first
        
        return VStack {
            Text(profile?.displayName ?? "")
                .font(.title2)
                .fontWeight(.bold)
            Text(profile?.handle ?? "")
                .foregroundStyle(.primary.opacity(ColorConstants.darkOpaque))
                .fontWeight(.medium)
            HStack {
                HStack(spacing: 5) {
                    Text("\(profile?.followerCount ?? 0)").bold()
                    Text("followers")
                }
                HStack(spacing: 5) {
                    Text("\(profile?.followCount ?? 0)").bold()
                    Text("following")
                }
                HStack(spacing: 5) {
                    Text("\(profile?.postCount ?? 0)").bold()
                    Text("posts")
                }
            }
            Text(profile?.description ?? "")
        }
        .font(.callout)
        .multilineTextAlignment(.center)
        .padding([.leading, .trailing, .bottom], PaddingConstants.defaultPadding)
    }
}

// MARK: - PROFILE SECTION
extension ProfileView {
    var profileSection: some View {
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
