//
//  SeperatorComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/27/25.
//

// MARK: - IMPORT
import SwiftUI

// MARK: - VIEW
struct SeperatorComponent: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(.gray.opacity(0.2))
            .frame(height: 0.45)
    }
}

// MARK: - PREVIEW
#Preview {
    SeperatorComponent()
        .frame(height: 100)
        .background(.thickMaterial)
}
