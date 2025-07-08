//
//  ExploreView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/2/25.
//

// MARK: - IMPORTS
import SwiftUI
import NukeUI
import FancyScrollView

// MARK: - EXPLORE VIEW
struct ExploreView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ScrollView {
            Spacer()
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ExploreView()
        .environment(appState)
}
