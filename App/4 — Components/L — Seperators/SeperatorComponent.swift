//
//  SeperatorComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/27/25.
//

// MARK: - Import
import SwiftUI

// MARK: - View
struct SeperatorComponent: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(.gray.opacity(0.2))
            .frame(height: 0.45)
    }
}

// MARK: - Preview
#Preview {
    SeperatorComponent()
        .frame(height: 100)
        .background(.thickMaterial)
}
