//
//  ExploreView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/13/25.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        VStack {
            HeaderFeature(location: .explore)
            Text("Hello, World!")
            Spacer()
        }
        .background(.standardBackground)
    }
}

#Preview {
    ExploreView()
}
