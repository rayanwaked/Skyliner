//
//  ReplyView.swift
//  Skyliner
//
//  Created by Rayan Waked on [Date]
//

import SwiftUI
import ATProtoKit
import PostHog

// MARK: - VIEW
struct ReplyView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var replyText: String = ""
    @State private var isPosting: Bool = false
    
    let parentPost: PostItem
    let onReplyPosted: (() -> Void)?
    
    init(parentPost: PostItem, onReplyPosted: (() -> Void)? = nil) {
        self.parentPost = parentPost
        self.onReplyPosted = onReplyPosted
    }
    
    // MARK: - BODY
    var body: some View {
        VStack {
            header
            
            ScrollView {
                VStack(alignment: .leading, spacing: Padding.standard) {
                    parentPostPreview
                    replyComposer
                }
                .padding(.horizontal, Padding.standard)
            }
            
            Spacer()
            
            actions
        }
        .padding(.top, Padding.large)
        .padding(.bottom, Padding.standard)
        .background(.standardBackground.opacity(0.9))
        .onAppear {
            PostHogSDK.shared.capture("Reply View")
        }
    }
}

// MARK: - HEADER
extension ReplyView {
    var header: some View {
        HStack {
            Spacer()
            
            Text("Reply")
                .fontWeight(.medium)
                .onTapGesture {
                    routerCoordinator.showingReply = false
                }
            
            Spacer()
        }
        .padding(.horizontal, Padding.standard)
        .padding(.bottom, Padding.standard)
    }
}

// MARK: - PARENT POST PREVIEW
extension ReplyView {
    var parentPostPreview: some View {
        VStack(alignment: .leading, spacing: Padding.small) {
            HStack(alignment: .top, spacing: Padding.small) {
                ProfilePictureComponent(
                    isUser: false,
                    profilePictureURL: parentPost.imageURL,
                    size: .small
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(parentPost.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Text("@\(parentPost.handle)")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                        
                        Text("· \(parentPost.time)")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    
                    Text(parentPost.message)
                        .font(.caption)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            HStack(spacing: Padding.tiny) {
                Image(systemName: "arrow.turn.down.right")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Text("Replying to @\(parentPost.handle)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(Padding.small)
        .background(.gray.opacity(Opacity.soft))
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    }
}

// MARK: - REPLY COMPOSER
extension ReplyView {
    var replyComposer: some View {
        HStack(alignment: .top, spacing: Padding.small) {
            ProfilePictureComponent()
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $replyText)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .disabled(isPosting)
                
                if replyText.isEmpty {
                    Text("Post your reply...")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - ACTIONS
extension ReplyView {
    var actions: some View {
        HStack {
            Text("\(replyText.count)/300")
                .font(.caption)
                .foregroundStyle(replyText.count > 300 ? .red : .gray)
            
            Spacer()
            
            ButtonComponent(
                "Reply",
                haptic: .success,
                action: {
                    Task {
                        await postReply()
                    }
                }
            )
            .frame(width: Screen.width * 0.25)
            .opacity(isPosting ? 0.5 : 1.0)
            .overlay {
                if isPosting {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        }
        .padding(.horizontal, Padding.standard)
    }
}

// MARK: - METHODS
extension ReplyView {
    func postReply() async {
        isPosting = true
        
        do {
            // Simply use the createReply method from PostManager
            try await appState.postManager.createReply(to: parentPost, text: replyText)
            
            hapticFeedback(.success)
            onReplyPosted?()
            routerCoordinator.showingReply = false
            dismiss()
            
        } catch {
            print("❌ Failed to post reply: \(error)")
            hapticFeedback(.error)
            isPosting = false
        }
    }
}

//// MARK: - PREVIEW
//#Preview {
//    @Previewable @State var appState: AppState = .init()
//    
//    let samplePost = PostItem(
//        authorDID: "did:plc:sample",
//        postID: "at://sample/post",
//        imageURL: nil,
//        name: "Sample User",
//        handle: "sampleuser.bsky.social",
//        time: "2m",
//        message: "This is a sample post that we're replying to.",
//        embed: nil,
//        rawPost: AppBskyLexicon.Feed.PostViewDefinition(
//            uri: "at://sample/post",
//            cid: "samplecid",
//            author: AppBskyLexicon.Actor.ProfileViewBasicDefinition(
//                actorDID: "did:plc:sample",
//                actorHandle: "sampleuser.bsky.social",
//                displayName: "Sample User",
//                avatarImageURL: nil,
//                associated: nil,
//                viewer: nil,
//                labels: nil,
//                createdAt: nil
//            ),
//            record: UnknownType(type: "app.bsky.feed.post"),
//            embed: nil,
//            replyCount: 0,
//            repostCount: 0,
//            likeCount: 0,
//            quoteCount: 0,
//            indexedAt: Date(),
//            viewer: nil,
//            labels: nil,
//            threadgate: nil
//        )
//    )
//    
//    ReplyView(parentPost: samplePost)
//        .environment(appState)
//}

