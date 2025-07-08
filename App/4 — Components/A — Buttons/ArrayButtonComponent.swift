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
struct ArrayButtonComponent<T: Hashable, Content: View>: View {
    // MARK: - VARIABLES
    var array: [T] = []
    var action: () -> Void
    var content: (T) -> Content
    
    // MARK: - BODY
    var body: some View {
        ScrollView(.horizontal) {
            SafeGlassEffectContainer {
                HStack {
                    ForEach(array, id: \.self) { item in
                        content(item)
                    }
                    .padding(PaddingConstants.smallPadding)
                    .safeInteractiveGlassEffect(tint: .blue.opacity(ColorConstants.lightOpaque))
                    .shadow(radius: 0)
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
        array: [FeedItem(displayName: "One"), FeedItem(displayName: "Two")],
        action: {},
        content: { feed in
            Text(feed.displayName)
        }
    )
}
