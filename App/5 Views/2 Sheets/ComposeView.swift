//
//  ComposeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import ATProtoKit
import PostHog
import os.log

// MARK: - VIEW
struct ComposeView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    @State private var postText: String = ""
    @State private var isPosting: Bool = false
    @State private var errorMessage: String?
    
    // MARK: - BODY
    var body: some View {
        VStack {
            Text("Compose a post")
                .fontWeight(.medium)
            
            HStack(alignment: .top) {
                ProfilePictureComponent()
                textField
            }
            
            Spacer()
            
            actions
        }
        .padding(.horizontal, Padding.standard)
        .padding(.top, Padding.large)
        .padding(.bottom, Padding.standard)
        .background(.standardBackground.opacity(0.9))
        .onAppear {
            PostHogSDK.shared.capture("Compose View")
        }
    }
}

// MARK: - TEXT FIELD
extension ComposeView {
    var textField: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $postText)
                .scrollContentBackground(.hidden)
                .background(.clear)
            if postText.isEmpty {
                Text("What's up?")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - ACTIONS
extension ComposeView {
    var actions: some View {
        VStack(spacing: Padding.small) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
            
            HStack {
                Spacer()
                
                ButtonComponent(
                    isPosting ? "Posting..." : "Post",
                    haptic: .success,
                    action: {
                        Task {
                            await createPost()
                        }
                    })
                    .frame(width: Screen.width * 0.65)
                    .disabled(isPosting || postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                ButtonComponent(
                    systemName: "xmark" ,
                    variation: .secondary,
                    size: .compose,
                    haptic: .soft,
                    action: {
                        routerCoordinator.showingCreate.toggle()
                })
                .disabled(isPosting)
            }
        }
    }
    
    private func createPost() async {
        guard !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isPosting = true
        errorMessage = nil
        
        do {
            _ = try await appState.clientManager?.bluesky.createPostRecord(text: postText)
            AppLogger.posts.info("Post created successfully")
            routerCoordinator.showingCreate.toggle()
        } catch {
            AppLogger.posts.error("Failed to create post: \(error.localizedDescription)")
            withAnimation {
                errorMessage = "Failed to post. Please try again."
            }
            hapticFeedback(.error)
        }
        
        isPosting = false
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    ComposeView()
        .environment(appState)
        .environment(routerCoordinator)
}
