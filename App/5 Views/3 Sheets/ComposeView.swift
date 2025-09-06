//
//  ComposeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 9/1/25.
//

import SwiftUI
import ATProtoKit
import SwiftyBeaver

// MARK: - VIEW
struct ComposeView: View {
    //  MARK: - PROPERTIES
    @Environment(AppState.self) var appState
    @Environment(Coordinator.self) var coordinator
    @State var composeMessage = ""
    
    //  MARK: - BODY
    var body: some View {
        VStack(alignment: .leading) {
            Text("Compose")
                .font(.smaller(.title3).bold())
            
            TextField(
                "Share something with the world",
                text: $composeMessage,
                axis: .vertical
            )
            
            Spacer()
            
            toolBar
        }
        .padding(Padding.large) // Inline content padding
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.standardBackground.opacity(Opacity.standard))
        .background(.thinMaterial)
        .backport
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: Radius.large))
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .padding(.horizontal, Padding.small) // Floating card design
    }
}

// MARK: - TOOLBAR
extension ComposeView {
    var toolBar: some View {
        HStack {
            ButtonComponent(
                "Cancel",
                variation: .tertiary,
                size: .standard) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        coordinator.showingSheet = false
                    }
                }
                .padding(.trailing, Screen.width * 0.2)
            
            Spacer()
            
            ButtonComponent(
                "Create post",
                variation: .primary,
                size: .standard) {
                    Task {
                        do {
                            _ = try await appState.clientManager?.bluesky
                                .createPostRecord(text: composeMessage)
                            
                            withAnimation(.easeInOut(duration: 0.25)) {
                                coordinator.showingSheet = false
                            }
                        } catch {
                            log.error(error)
                        }
                    }
                }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    @Previewable @State var coordinator = Coordinator()
    
    ComposeView()
        .environment(appState)
        .environment(coordinator)
}
