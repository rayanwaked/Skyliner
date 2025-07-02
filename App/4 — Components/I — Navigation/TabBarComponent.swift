//
//  TabBarComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/23/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - VIEWS
struct TabBarComponent: View {
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - FUNCTIONS
    func throwFunc() {
        print("throw")
    }
    
    // MARK: - BODY
    var body: some View {
        HStack {
            HStack {
                // MARK: - Navigation
                HStack {
                    TabBarButton(systemImage: "airplane.up.forward") {
                        
                    }
                    Spacer()
                    TabBarButton(systemImage: "magnifyingglass") {
                        
                    }
                    Spacer()
                    TabBarButton(systemImage: "bell") {
                        
                    }
                    Spacer()
                    TabBarButton(systemImage: "person") {
                        
                    }
                }
                .foregroundStyle(.primary)
                .padding([.leading, .trailing], PaddingConstants.defaultPadding * 1.5)
                .padding([.top, .bottom], PaddingConstants.defaultPadding / 2)
                .glassEffect(.regular.tint(.clear).interactive())
                
                // MARK: - Action
                CompactButtonComponent(
                    action: throwFunc,
                    label: Image(systemName: "plus"),
                    variation: .primary, placement: .tabBar
                )
            }
        }
        .padding([.leading, .trailing], PaddingConstants.defaultPadding)
        .padding(.bottom, -10)
        .shadow(
            color: colorScheme == .light ? .black
                .opacity(0.25) : .black
                .opacity(0.8),
            radius: LayoutConstants.defaultRadius,
            x: 0,
            y: PaddingConstants.defaultPadding * 2.5
        )
    }
}

// MARK: - TAB BAR BUTTON
private struct TabBarButton: View {
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemImage)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(width: SizeConstants.screenWidth * 0.05, height: SizeConstants.screenHeight * 0.05)
        }
    }
}

#Preview {
    TabBarComponent()
}
