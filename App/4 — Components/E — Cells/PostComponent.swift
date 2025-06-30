//
//  PostComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/26/25.
//

// MARK: - Import
import SwiftUI

// MARK: - View
struct PostComponent: View, Hashable {
    var id: String = ""
    var displayName: String = ""
    var handle: String = ""
    var time: String = ""
    var content: String = ""

    // MARK: - Body
    var body: some View {
        GlassEffectContainer {
            HStack(alignment: .top) {
                profilePicture
                VStack(alignment: .leading) {
                    account
                    text
                }
            }
            .padding(.top, PaddingConstants.smallPadding)
            .padding([.leading, .trailing], PaddingConstants.defaultPadding)
            
            SeperatorComponent()
        }
    }
}

// MARK: - Extension
extension PostComponent {
    // MARK: - Profile Picture
    @ViewBuilder
    var profilePicture: some View {
        Circle()
            .foregroundStyle(.blue)
            .frame(maxWidth: 45, maxHeight: 45)
            .glassEffect()
    }
    
    // MARK: - Account
    var account: some View {
        HStack {
            Text(displayName)
                .bold()
                .fixedSize()
            Text("@\(handle)")
                .foregroundStyle(.primary.opacity(0.6))
                .font(.subheadline)
            Text("·")
            Text(time)
                .foregroundStyle(.primary.opacity(0.6))
                .font(.subheadline)
            Spacer()
        }
        .lineLimit(1)
        .padding(.bottom, PaddingConstants.defaultPadding * 0.05)
    }
    
    // MARK: - Text
    var text: some View {
        Text(content)
            .font(.subheadline)
            .fontWeight(.regular)
            .padding(.bottom, PaddingConstants.defaultPadding / 4)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var id: String = "1"
    @Previewable @State var displayName: String = "Skyliner"
    @Previewable @State var handle: String = "skyline.app"
    @Previewable @State var time: String = "1h"
    @Previewable @State var content: String = "Ready for takeoff!"
    
    PostComponent(id: id, displayName: displayName, handle: handle, time: time, content: content)
}

