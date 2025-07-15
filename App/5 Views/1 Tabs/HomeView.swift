//
//  HomeView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

struct HomeView: View {
    @State private var scrollDistance: Double = 0.0
    @State private var previousScrollDistance: Double = 0
    @State private var headerShowing: Bool = true
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack {
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, Screen.height * 0.1)
            }
            .onScrollGeometryChange(for: Double.self) { geo in
                geo.contentOffset.y
            } action: { oldValue, newValue in
                scrollDistance = newValue
                if scrollDistance < Screen.height * 0.025 {
                    headerShowing = true
                } else {
                    if scrollDistance < oldValue {
                        headerShowing = true
                    } else {
                        headerShowing = false
                    }
                }
                
            }
            
            HeaderFeature()
                .baselineOffset(headerShowing ? 0.0 : 200)
                .opacity(headerShowing ? 1.0 : 0.0)
                .transition(headerShowing ? .move(edge: .top) : .move(edge: .bottom))
                .animation(
                    .snappy(duration: 0.5),
                    value: headerShowing
                )
        }
    }
}

#Preview {
    HomeView()
}
