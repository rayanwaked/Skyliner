//
//  AccountView.swift
//  Skyliner
//
//  Created by Rayan Waked on 9/17/25.
//

import SwiftUI

// MARK: - VIEW
struct AccountView: View {
    @Environment(AppState.self) private var appState
    var accountModel = ProfileManager(userDID: "")
    var accountDID: String
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(accountModel.profilePosts, id: \.postID) { post in
                    PostFeature(feed: post)
                }
                .padding(.top, Padding.large)
            }
            .background(.standardBackground)
            .scrollIndicators(.never)
            .navigationTitle(Text("Profile"))
        }
        .onAppear {
            Task {
                accountModel.userDID = accountDID
                await accountModel.loadProfile()
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    
    AccountView(accountDID: "")
        .environment(appState)
}
