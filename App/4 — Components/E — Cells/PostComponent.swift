//
//  PostComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - Import
import SwiftUI

// MARK: - View
struct PostComponent: View {
    var displayName: String = ""
    var handle: String = ""
    var time: String = ""
    var content: String = ""

    // MARK: - Body
    var body: some View {
        GlassEffectContainer {
            HStack(alignment: .top) {
                profilePicture
                VStack(alignment: .leading) {
                    account
                    text
//                    actions
                }
            }
            .padding(.top, PaddingConstants.smallPadding)
            .padding([.leading, .trailing], PaddingConstants.defaultPadding)
            
            SeperatorComponent()
        }
    }
}

// MARK: - Extension
extension PostComponent {
    // MARK: - Profile Picture
    @ViewBuilder
    var profilePicture: some View {
//        if let avatarURL = post.author.avatarImageURL {
//            AsyncImage(url: avatarURL) { phase in
//                switch phase {
//                case .empty:
//                    Circle()
//                        .foregroundStyle(.blue)
//                        .frame(maxWidth: 45, maxHeight: 45)
//                        .glassEffect()
//                case .success(let image):
//                    image
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 45, height: 45)
//                        .clipShape(Circle())
//                        .glassEffect()
//                case .failure:
//                    Circle()
//                        .foregroundStyle(.blue)
//                        .frame(maxWidth: 45, maxHeight: 45)
//                        .glassEffect()
//                @unknown default:
//                    Circle()
//                        .foregroundStyle(.blue)
//                        .frame(maxWidth: 45, maxHeight: 45)
//                        .glassEffect()
//                }
//            }
//        } else {
            Circle()
                .foregroundStyle(.blue)
                .frame(maxWidth: 45, maxHeight: 45)
//                .glassEffect()
//        }
    }
    
    // MARK: - Account
    var account: some View {
        HStack {
            Text(displayName)
                .bold()
                .fixedSize()
            Text("@\(handle)")
                .foregroundStyle(.primary.opacity(0.6))
                .font(.subheadline)
            Text("·")
            Text(time)
                .foregroundStyle(.primary.opacity(0.6))
                .font(.subheadline)
        }
        .lineLimit(1)
        .padding(.bottom, PaddingConstants.defaultPadding * 0.05)
    }
    
    // MARK: - Text
    var text: some View {
        Text(content)
            .font(.subheadline)
            .fontWeight(.regular)
            .padding(.bottom, PaddingConstants.defaultPadding / 4)
    }
    
//    // MARK: - Actions
//    @ViewBuilder
//    var actions: some View {
//        HStack {
//            HStack {
//                Image(systemName: "message")
//                Text("\(post.replyCount)")
//            }
//            Spacer()
//            Image(systemName: "heart")
//            Text("\(post.likeCount)")
//                .onTapGesture {
//                    Task {
//                        await context.toggleLike()
//                    }
//                }
//            Spacer()
//            HStack {
//                Image(systemName: "arrowshape.turn.up.left")
//                Text("\(post.repostCount)")
//            }
//                .onTapGesture {
//                    Task {
//                        await context.toggleRepost()
//                    }
//                }
//            Spacer()
//            Image(systemName: "square.and.arrow.up")
//            Spacer()
//            Image(systemName: "option")
//        }
//        .foregroundStyle(.primary.opacity(0.55))
//        .font(.subheadline)
//        .padding(standardPadding * 0.05)
//    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var displayName: String = "Joseph Snow"
    @Previewable @State var handle: String = "joseph.snow"
    @Previewable @State var time: String = "1h"
    @Previewable @State var post: String = "Heyyy"
    @Previewable @State var context: String = "hey"
    PostComponent()
}

