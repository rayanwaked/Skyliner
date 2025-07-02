//
//  ProfileView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/2/25.
//

// MARK: - IMPORTS
import SwiftUI
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
        .ignoresSafeArea(.container)
    }
}

// MARK: - BANNER SECTION
extension ProfileView {
    var bannerSection: some View {
        @State var profile = appState.profileModel.first
        
        return AsyncImage(url: profile?.banner) { result in
            result.image?
                .resizable()
                .clipShape(Rectangle())
                .scaledToFill()
        }
        .frame(width: SizeConstants.screenWidth * 1, height: SizeConstants.screenHeight * 0.2)
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
        .frame(width: SizeConstants.screenWidth * 0.2, height: SizeConstants.screenWidth * 0.2)
    }
}

// MARK: - DETAILS SECTION
extension ProfileView {
    var detailsSection: some View {
        @State var profile = appState.profileModel.first
        
        return VStack {
            Text(profile?.displayName ?? "")
            Text(profile?.description ?? "")
            Text(profile?.handle ?? "")
            Text("\(profile?.followCount ?? 0)")
            Text("\(profile?.followerCount ?? 0)")
            Text("\(profile?.postCount ?? 0)")
        }
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
