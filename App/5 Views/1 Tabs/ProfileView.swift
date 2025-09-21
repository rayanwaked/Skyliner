//
//  ProfileView.swift
//  Skyliner
//
//  Created by Rayan Waked on 9/17/25.
//

import SwiftUI

// MARK: - VIEW
struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var userModel: ProfileManager?
    @StateObject private var bannerManager = BannerPositionManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let userModel = userModel {
                    BannerFeature(manager: bannerManager)

                    ScrollView {
                        ForEach(userModel.profilePosts, id: \.postID) { post in
                            PostFeature(feed: post)
                        }
                        .padding(.top, Padding.large)
                    }
                    .scrollIndicators(.never)
                    .refreshable {
                        await userModel.refreshProfile()
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(.standardBackground)
            .navigationTitle("Profile")
            .onAppear {
                let userDID = appState.userDID ?? ""
                self.userModel = ProfileManager(userDID: userDID, appState: appState)
                
                Task {
                    await userModel?.loadProfile()
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    
    ProfileView()
        .environment(appState)
}
