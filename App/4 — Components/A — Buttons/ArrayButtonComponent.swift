//
//  ArrayButtonComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/4/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - FEED ITEM
struct FeedItem: Hashable {
    let displayName: String
}

// MARK: - VIEW
struct ArrayButtonComponent: View {
    // MARK: - VARIABLES
    var feeds: [FeedItem] = []
    var action: () -> Void
    
    // MARK: - BODY
    var body: some View {
        ScrollView(.horizontal) {
            GlassEffectContainer {
                HStack {
                    ForEach(feeds, id: \.self) { feed in
                        Text(feed.displayName)
                    }
                    .padding(PaddingConstants.smallPadding)
                    .glassEffect(
                        .regular
                            .interactive()
                            .tint(.blue.opacity(ColorConstants.defaultOpaque))
                    )
                    .padding([.top, .bottom], PaddingConstants.tinyPadding / 1.3)
                    .hapticAction(.soft, perform: { action() })
                }
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding([.leading, .trailing], PaddingConstants.defaultPadding)
            }
        }
        .padding(.top, PaddingConstants.tinyPadding)
        .scrollIndicators(.hidden)
    }
}

// MARK: - PREVIEW
#Preview {
    ArrayButtonComponent(
        feeds: [FeedItem(displayName: "One"), FeedItem(displayName: "Two")],
        action: {}
    )
}
