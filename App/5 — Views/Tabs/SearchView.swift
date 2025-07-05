//
//  SearchView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/2/25.
//

// MARK: - IMPORTS
import SwiftUI
import FancyScrollView
import NukeUI

struct SearchView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Spacer()
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    SearchView()
        .environment(appState)
}
