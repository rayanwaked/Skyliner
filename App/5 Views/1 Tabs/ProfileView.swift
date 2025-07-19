//
//  ProfileView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

// MARK: - VIEW
struct ProfileView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @StateObject private var bannerManager = BannerFrameManager()
    @State private var userProfile: AccountManager?
    
    // MARK: - BODY
    var body: some View {
        ScrollView {
            subBanner
        }
        .scrollIndicators(.hidden)
        .onAppear {
            if userProfile == nil {
                userProfile = appState.accountManager
            }
        }
    }
}

extension ProfileView {
    var subBanner: some View {
        HStack {
            ProfilePictureComponent(size: .xlarge)
            profileStats
        }
        .padding(.horizontal, Padding.standard)
        .padding(.vertical, Padding.standard)
    }
}

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

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ProfileView()
        .environment(appState)
}
