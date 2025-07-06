//
//  PostComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - IMPORT
import SwiftUI
import NukeUI

// MARK: - VIEW
struct PostComponent: View {
    @Environment(AppState.self) var appState
    var post: PostModel

    // MARK: - BODY
    var body: some View {
        Button {
            
        } label: {
            VStack {
                HStack(alignment: .top) {
                    profilePicture
                    VStack(alignment: .leading) {
                        account
                        text
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
        .background(.defaultBackground)
        .padding(.bottom, PaddingConstants.tinyPadding)
    }
}

// MARK: - EXTENSION
extension PostComponent {
    // MARK: - PROFILE PICTURE
    @ViewBuilder
    var profilePicture: some View {
        if post.author.avatarImageURL != nil {
            LazyImage(url: post.author.avatarImageURL) { result in
                result.image?
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFit()
                    .frame(maxWidth: SizeConstants.screenWidth * 0.125, maxHeight: SizeConstants.screenWidth * 0.125)
                    .glassEffect()
            }
        } else {
            Circle()
                .foregroundStyle(.blue)
                .frame(maxWidth: SizeConstants.screenWidth * 0.125, maxHeight: SizeConstants.screenWidth * 0.125)
                .glassEffect()
        }
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
        .padding(.bottom, PaddingConstants.tinyPadding / 4)
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

