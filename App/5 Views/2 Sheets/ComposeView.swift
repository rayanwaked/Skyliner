//
//  ComposeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI
import ATProtoKit

// MARK: - VIEW
struct ComposeView: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    @State private var postText: String = ""
    
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
        HStack {
            Spacer()
            
            ButtonComponent(
                "Post",
                haptic: .success,
                action: {
                    Task {
                        do {
                            _ = try await appState.clientManager?.bluesky.createPostRecord(text: postText)
                            routerCoordinator.showingCreate.toggle()
                        } catch {
                            print("Failed to post: \(error)")
                        }
                    }
                })
                .frame(width: Screen.width * 0.65)
            
            ButtonComponent(
                systemName: "xmark" ,
                variation: .secondary,
                size: .compose,
                haptic: .soft,
                action: {
                    routerCoordinator.showingCreate.toggle()
            })
        }
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
