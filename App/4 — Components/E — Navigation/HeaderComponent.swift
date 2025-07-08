//
//  HeaderComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/24/25.
//

// MARK: - IMPORT
import SwiftUI
import NukeUI

// MARK: - VIEW
struct HeaderComponent: View {
    @Environment(AppState.self) private var appState
    var feeds: [FeedModel] = []
    var trends: [TrendModel] = []
    var isHome: Bool = true
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            if isHome {
                settingsSection
                feedSection
                trendingSection
            } else {
                settingsSection
                    .padding(.bottom, PaddingConstants.smallPadding)
            }
            SeperatorComponent()
        }

    }
}

// MARK: - SETTINGS SECTION
private extension HeaderComponent {
    var settingsSection: some View {
        HStack {
            Spacer()
            HStack {
                if isHome {
                    CompactButtonComponent(
                        action: {
                            Task {
                                try await appState.authenticationManager.logout()
                            }
                        },
                        label: Image(systemName: "command"),
                        variation: .quaternary,
                        placement: .header
                    )
                
                    CompactButtonComponent(
                        action: {},
                        label: Image(systemName: "number"),
                        variation: .quaternary,
                        placement: .header
                    )
                }
            }
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .overlay(
            HStack {
                Image("SkylinerEmoji")
                    .resizable()
                    .scaledToFit()
                    .frame(width: SizeConstants.screenWidth * 0.08, height: SizeConstants.screenWidth * 0.08)
                Text(isHome ? "Skyliner" : "Notifications")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }, alignment: .bottomLeading)
        .padding(.leading, PaddingConstants.defaultPadding)
    }
}

// MARK: - FEED SECTION
private extension HeaderComponent {
    var feedSection: some View {
        ArrayButtonComponent(
            array: feeds,
            action: {},
            content: { feed in
                Text(feed.displayName)
            }
        )
    }
}

// MARK: - TRENDING SECTION
private extension HeaderComponent {
    var trendingSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: PaddingConstants.smallPadding) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.accent)
                
                ForEach(trends, id: \.self) { trend in
                    Text(trend.displayName ?? "")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            .primary.opacity(ColorConstants.darkOpaque)
                        )
                }
            }
            .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        }
        .padding([.top, .bottom], PaddingConstants.smallPadding)
        .scrollIndicators(.hidden)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    HeaderComponent(feeds: FeedModel.placeholders, trends: TrendModel.placeholders)
}
