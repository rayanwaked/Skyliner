//
//  PostComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - IMPORT
import SwiftUI

// MARK: - VIEW
struct PostComponent: View, Hashable {
    var post: PostModel

    // MARK: - BODY
    var body: some View {
        GlassEffectContainer {
            HStack(alignment: .top) {
                profilePicture
                VStack(alignment: .leading) {
                    account
                    text
                }
            }
            .padding(.top, PaddingConstants.smallPadding)
            .padding([.leading, .trailing], PaddingConstants.defaultPadding)
            
            SeperatorComponent()
        }
    }
}

// MARK: - EXTENSION
extension PostComponent {
    // MARK: - PROFILE PICTURE
    @ViewBuilder
    var profilePicture: some View {
        Circle()
            .foregroundStyle(.blue)
            .frame(maxWidth: 45, maxHeight: 45)
            .glassEffect()
    }
    
    // MARK: - ACCOUNT
    var account: some View {
        HStack {
            Text(post.author.displayName ?? "")
                .bold()
                .fixedSize()
            Text("@\(post.author.handle)")
                .foregroundStyle(.primary.opacity(0.6))
                .font(.subheadline)
            Text("·")
            Text(post.indexAtFormatted)
                .foregroundStyle(.primary.opacity(0.6))
                .font(.subheadline)
            Spacer()
        }
        .lineLimit(1)
        .padding(.bottom, PaddingConstants.defaultPadding * 0.05)
    }
    
    // MARK: - TEXT
    var text: some View {
        Text(post.content)
            .font(.subheadline)
            .fontWeight(.regular)
            .padding(.bottom, PaddingConstants.defaultPadding / 4)
    }
}

// MARK: - PREVIEW
#Preview {
    PostComponent(post: PostModel.placeholders.first!)
}

