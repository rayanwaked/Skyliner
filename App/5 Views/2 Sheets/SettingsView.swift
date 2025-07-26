//
//  SettingsView.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/25/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(HeaderCoordinator.self) private var headerCoordinator
    
    var body: some View {
        Toggle(
            "Show header trends",
            isOn: Binding(
                get: { headerCoordinator.showingTrends },
                set: { headerCoordinator.showingTrends = $0 }
            )
            
        )
        .padding(.horizontal, Padding.standard)
    }
}

#Preview {
    @Previewable @State var headerCoordinator: HeaderCoordinator = .init()
    
    SettingsView()
        .environment(headerCoordinator)
}
