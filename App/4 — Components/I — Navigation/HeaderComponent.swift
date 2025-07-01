//
//  HeaderComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/24/25.
//

// MARK: - Import
import SwiftUI

// MARK: - View
struct HeaderComponent: View {
    @State var feeds: [String] = []
    @State var trends: [String] = []
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            settingsSection
            feedSection
            SeperatorComponent()
            trendingSection
            SeperatorComponent()
        }
    }
}

private extension HeaderComponent {
    // MARK: - Settings Section
    @ViewBuilder
    private var settingsSection: some View {
        HStack {
            Spacer()
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "command")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(PaddingConstants.smallPadding)
                .glassEffect()
                
                Button {

                } label: {
                    Image(systemName: "number")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding(PaddingConstants.smallPadding)
                .glassEffect()
            }
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .overlay(
            HStack {
                Text("Skyliner")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
            }, alignment: .bottomLeading)
        .padding(.leading, PaddingConstants.defaultPadding)
    }

    // MARK: - Feed Section
    @ViewBuilder
    private var feedSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: PaddingConstants.horizontalPadding) {
                ForEach(feeds, id: \.self) { feed in
                    Text(feed)
                }
            }
            .font(.callout)
            .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        }
        .padding(.top, PaddingConstants.verticalPadding)
        .padding(.bottom, PaddingConstants.verticalPadding)
        .scrollIndicators(.hidden)
    }

    // MARK: - Trending Section
    @ViewBuilder
    private var trendingSection: some View {
        ScrollView(.horizontal) {
            HStack(spacing: PaddingConstants.horizontalPadding) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.accent)
                
                ForEach(trends, id: \.self) { trend in
                    Text(trend)
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

// MARK: - Preview
#Preview {
    @Previewable @State var feeds = ["Discover", "Trending", "Development", "Science", "Nature", "Memes"]
    @Previewable @State var trends = ["Caturday", "WWDC25", "TSMC", "Bluesky", "Tokyo", "Cockatoo"]
    
    HeaderComponent(feeds: feeds, trends: trends)
}
