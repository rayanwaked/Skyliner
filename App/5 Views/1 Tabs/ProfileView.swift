//
//  ProfileView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
internal import Combine

// MARK: - VIEW
struct ProfileView: View {
    // MARK: - PROPERTIES
    @StateObject private var bannerManager = BannerFrameManager()
    
    // MARK: - BODY
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                ForEach(1..<100) { _ in
                    Text("Hello")
                }
                .padding(.top, bannerManager.bannerHeight * 1.15)
            }
            .scrollIndicators(.hidden)
            .bannerScrollBehavior(bannerManager)
            
            BannerComponent(bannerManager: bannerManager)
        }
        .ignoresSafeArea(.all)
    }
}

// MARK: - PREVIEW
#Preview {
    ProfileView()
}
