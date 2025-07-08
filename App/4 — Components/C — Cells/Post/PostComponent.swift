//
//  PostComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - IMPORTS
import SwiftUI
import NukeUI

// MARK: - VIEW
struct PostComponent: View {
    @Environment(AppState.self) var appState
    var post: PostModel

    var body: some View {
        Button {
            
        } label: {
            VStack {
                HStack(alignment: .top) {
                    profilePicture
                    VStack(alignment: .leading) {
                        account
                        text
                        embeds
                        actions
                    }
                    .multilineTextAlignment(.leading)
                    .padding(.leading, PaddingConstants.smallPadding)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing], PaddingConstants.defaultPadding)
                
                SeperatorComponent()
            }
        }
        .foregroundStyle(.primary)
        .padding(.bottom, PaddingConstants.tinyPadding)
    }
}

// MARK: - PROFILE PICTURE
extension PostComponent {
    @ViewBuilder
    var profilePicture: some View {
        if post.author.avatarImageURL != nil {
            LazyImage(url: post.author.avatarImageURL) { result in
                result.image?
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFit()
                    .frame(maxWidth: SizeConstants.screenWidth * 0.125, maxHeight: SizeConstants.screenWidth * 0.125)
                    .safeGlassEffect()
            }
        } else {
            Circle()
                .foregroundStyle(.blue)
                .frame(maxWidth: SizeConstants.screenWidth * 0.125, maxHeight: SizeConstants.screenWidth * 0.125)
                .safeGlassEffect()
        }
    }
    
    @ViewBuilder
    var embeds: some View {
        Button {
            
        } label: {
            PostEmbeds(embed: post.embed)
        }
        .safeGlassEffect(
            in: RoundedRectangle(cornerRadius: RadiusConstants.smallRadius)
        )
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
            Text(DateHelper.formattedRelativeDate(from: post.indexedAt))
                .foregroundStyle(.primary.opacity(0.6))
                .font(.subheadline)
                .fixedSize()
        }
        .lineLimit(1)
    }
    
    // MARK: - TEXT
    var text: some View {
        Text(post.content)
            .font(.subheadline)
            .fontWeight(.regular)
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    PostComponent(post: PostModel.placeholders.first!)
        .environment(appState)
}

