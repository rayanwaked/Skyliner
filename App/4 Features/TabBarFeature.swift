//
//  TabBarFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

import SwiftUI

// MARK: - VIEW
struct TabBarFeature: View {
    @Environment(AppState.self) private var appState
    @State private var profileModel: ProfileManager?
    
    var userDID: String
    var homeAction: () -> Void
    var exploreAction: () -> Void
    var notificationAction: () -> Void
    var profileAction: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button { homeAction() } label: {
                    Image(systemName: "airplane.up.right")
                }
                Spacer()
                Button { exploreAction() } label: {
                    Image(systemName: "binoculars.fill")
                }
                Spacer()
                Button { notificationAction() } label: {
                    Image(systemName: "bell.fill")
                }
                Spacer()
                Button { profileAction() } label: {
                    ProfilePictureComponent(
                        profilePictureURL: profileModel?.state.profilePictureURL,
                        size: .xsmall
                    )
                }
                Spacer()
            }
            .foregroundStyle(.primary)
            .font(.title2)
            .padding(.vertical, Padding.standard)
            .backport.glassEffect()
            .padding(.horizontal, Padding.standard)
        }
        .onAppear {
            let userDID = appState.userDID ?? ""
            self.profileModel = ProfileManager(userDID: userDID, appState: appState)
            
            Task {
                await profileModel?.loadProfile()
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    
    TabBarFeature(
        userDID: appState.userDID ?? "",
        homeAction: {},
        exploreAction: {},
        notificationAction: {},
        profileAction: {}
    )
    .environment(appState)
}
