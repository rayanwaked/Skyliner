//
//  HomeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var scrollHandler = HandleScrollChange()
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack {
                    ForEach(1..<102) { _ in
                        PostFeature()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, Screen.height * 0.125)
            }
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentOffset.y
            } action: { oldValue, newValue in
                scrollHandler
                    .updateVisibility(oldValue, newValue)
            }
            
            if scrollHandler.isVisible {
                HeaderFeature()
                    .zIndex(1)
                    .baselineOffset(scrollHandler.isVisible ? 0 : Screen.height * -1)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .offset(y: -Screen.height * 0.2).combined(with: .opacity)
                    ))
            }
        }
        .background(.standardBackground)
    }
}

#Preview {
    HomeView()
}
