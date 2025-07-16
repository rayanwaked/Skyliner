//
//  ArrayButtonComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/4/25.
//

import SwiftUI

// MARK: - FEED ITEM
struct FeedItem: Hashable {
    let displayName: String
}

// MARK: - VIEW
struct ArrayButtonComponent<T: Hashable, Content: View>: View {
    // MARK: - PROPERTIES
    let items: [T]
    let content: (T) -> Content
    let action: ((T) -> Void)?
    
    // MARK: - BODY
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(items, id: \.self) { item in
                    content(item)
                        .padding(Padding.small)
                        .backport.glassEffect(
                            .tintedAndInteractive(
                                color: .blue.opacity(Opacity.light),
                                isEnabled: true
                            )
                        )
                        .padding(.vertical, Padding.tiny / 1.3)
                        .hapticAction(.soft) { action?(item) }
                }
            }
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .padding(.horizontal, Padding.standard)
        }
        .padding(.top, Padding.tiny)
        .scrollIndicators(.hidden)
    }
}

// MARK: - PREVIEW
#Preview {
    ArrayButtonComponent(
        items: ["One", "Two", "Three"],
        content: { Text($0) },
        action: { print("Selected: \($0)") }
    )
    ArrayButtonComponent(
        items: ["One", "Two", "Three"],
        content: { Text($0) },
        action: { print("Selected: \($0)") }
    )
}
