//
//  ThreadFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/25/25.
//

import SwiftUI

// MARK: - VIEW
struct ThreadFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let postURI: String
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var threadManager: ThreadManager {
        appState.threadManager
    }
    
    // MARK: - BODY
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    loadingView
                } else if showError {
                    errorView
                } else {
                    threadContent
                }
            }
            .background(.standardBackground)
        }
        .task {
            await loadThread()
        }
    }
}

// MARK: - LOADING VIEW
extension ThreadFeature {
    var loadingView: some View {
        VStack(spacing: Padding.standard) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading thread...")
                .font(.smaller(.subheadline))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ERROR VIEW
extension ThreadFeature {
    var errorView: some View {
        VStack(spacing: Padding.standard) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text("Unable to load thread")
                .font(.headline)
            
            Text(errorMessage)
                .font(.smaller(.subheadline))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            ButtonComponent("Try Again", variation: .secondary, size: .compact) {
                Task {
                    await loadThread()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - THREAD CONTENT
extension ThreadFeature {
    var threadContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Parent post if available
                if let parentPost = threadManager.parentPost {
                    ThreadPostCell(
                        post: parentPost,
                        isMainPost: true,
                        threadItem: nil
                    )
                    .padding(.top, -Padding.small)
                    .padding(.bottom, Padding.small)
                }
                
                // Thread posts (filtered to avoid duplicates with parent post)
                ForEach(Array(filteredThreadItems.enumerated()), id: \.element.post.postID) { index, threadItem in
                    VStack(spacing: 0) {
                        ThreadPostCell(
                            post: threadItem.post,
                            isMainPost: false,
                            threadItem: threadItem
                        )
                    }
                }
            }
            .padding(.vertical, Padding.small)
        }
//        .refreshable {
//            await refreshThread()
//        }
    }
    
    /// Filters thread items to avoid showing duplicates, especially with the parent post
    private var filteredThreadItems: [ThreadItem] {
        let parentPostID = threadManager.parentPost?.postID
        
        // Remove duplicates by keeping track of seen post IDs
        var seenPostIDs = Set<String>()
        
        // Add parent post ID to seen set if it exists
        if let parentPostID = parentPostID {
            seenPostIDs.insert(parentPostID)
        }
        
        return threadManager.threads.filter { threadItem in
            let postID = threadItem.post.postID
            
            // Only include posts we haven't seen before
            if seenPostIDs.contains(postID) {
                return false
            } else {
                seenPostIDs.insert(postID)
                return true
            }
        }
    }
    
    private func threadLeadingPadding(for depth: Int) -> CGFloat {
        CGFloat(max(0, depth)) * 40 + 60
    }
}



// MARK: - METHODS
extension ThreadFeature {
    private func loadThread() async {
        isLoading = true
        showError = false
        
        await threadManager.loadThread(uri: postURI)
        
        withAnimation {
            isLoading = false
            if !threadManager.hasThreadData {
                showError = true
                errorMessage = "Could not load the thread. It may have been deleted or made private."
            }
        }
    }
    
    private func refreshThread() async {
        await threadManager.refreshThread(uri: postURI)
    }
}

//// MARK: - THREAD MANAGER EXTENSION
//extension ThreadManager: PostManaging {
//    var displayPosts: [PostItem] {
//        threads.map { $0.post }
//    }
//}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    ThreadFeature(postURI: "at://did:example/app.bsky.feed.post/example")
        .environment(appState)
        .environment(routerCoordinator)
}
