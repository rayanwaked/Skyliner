//
//  SearchView.swift
//  Skyliner
//
//  Created by Rayan Waked on 9/17/25.
//

import SwiftUI

// MARK: - VIEW
struct ExploreView: View {
    @Environment(AppState.self) private var appState
    private var exploreModel: ExploreManager { appState.exploreManager }
    private var trendsModel: TrendsManager { appState.trendsManager }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Padding.small) {
                    ForEach(trendsModel.trends, id: \.self) { trend in
                        Text("\(trend.description)")
                    }
                }
                .padding(.top, Padding.large)
            }
            .padding(.horizontal, Padding.standard)
            .frame(width: Screen.width, alignment: .leading)
            .background(.standardBackground)
            .scrollIndicators(.never)
            .navigationTitle(Text("Explore"))
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState = AppState()
    
    ExploreView()
        .environment(appState)
}
