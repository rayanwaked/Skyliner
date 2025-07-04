//
//  HeaderComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/24/25.
//

// MARK: - IMPORT
import SwiftUI

// MARK: - VIEW
struct HeaderComponent: View {
    var feeds: [FeedModel] = []
    var trends: [TrendModel] = []
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            settingsSection
            feedSection
            trendingSection
            SeperatorComponent()
        }
    }
}

private extension HeaderComponent {
    // MARK: - SETTINGS SECTION
    @ViewBuilder
    private var settingsSection: some View {
        HStack {
            Spacer()
            HStack {
                CompactButtonComponent(
                    action: {},
                    label: Image(systemName: "command"),
                    variation: .secondary,
                    placement: .header
                )
                
                CompactButtonComponent(
                    action: {},
                    label: Image(systemName: "number"),
                    variation: .secondary,
                    placement: .header
                )
            }
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .overlay(
            HStack {
                Text("Skyliner")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }, alignment: .bottomLeading)
        .padding(.leading, PaddingConstants.defaultPadding)
    }

    // MARK: - FEED SECTION
    @ViewBuilder
    private var feedSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: PaddingConstants.horizontalPadding) {
                ForEach(feeds, id: \.self) { feed in
                    Text(feed.displayName)
                }
                .padding(PaddingConstants.smallPadding)
                .glassEffect(
                    .regular
                        .interactive()
                        .tint(.defaultBackground.opacity(ColorConstants.softOpaque))
                )
            }
            .font(.callout)
            .fontWeight(.medium)
            .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        }
        .padding(.top, PaddingConstants.verticalPadding)
        .scrollIndicators(.hidden)
    }

    // MARK: - TRENDING SECTION
    @ViewBuilder
    private var trendingSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: PaddingConstants.horizontalPadding) {
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
        .padding([.top, .bottom], PaddingConstants.verticalPadding)
        .scrollIndicators(.hidden)
    }
}

// MARK: - PREVIEW
#Preview {
    HeaderComponent(feeds: FeedModel.placeholders, trends: TrendModel.placeholders)
}

