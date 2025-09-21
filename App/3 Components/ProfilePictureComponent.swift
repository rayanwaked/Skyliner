//
//  ProfilePictureComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/15/25.
//

import SwiftUI
import NukeUI

// MARK: - ENUM
extension ProfilePictureComponent {
    enum Size {
        case xsmall, small, medium, large, xlarge
        
        @MainActor
        var frame: CGSize {
            switch self {
            case .xsmall:
                CGSize(width: Screen.width * 0.08, height: Screen.width * 0.08)
            case .small:
                CGSize(width: Screen.width * 0.1, height: Screen.width * 0.1)
            case .medium:
                CGSize(width: Screen.width * 0.115, height: Screen.width * 0.115)
            case .large:
                CGSize(width: Screen.width * 0.2, height: Screen.width * 0.2)
            case .xlarge:
                CGSize(width: Screen.width * 0.29, height: Screen.width * 0.29)
            }
        }
    }
}


// MARK: - VIEW
struct ProfilePictureComponent: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
 
    var profilePictureURL: URL? = nil
    var size: Size = .medium
    
    // MARK: - BODY
    var body: some View {
        Group {
            if (profilePictureURL != nil) {
                LazyImage(url: profilePictureURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Circle()
                            .fill(Color.secondary.opacity(0.3))
                    }
                }
                .frame(width: size.frame.width, height: size.frame.height)
                .clipShape(Circle())
            } else {
                Circle()
                    .font(.smaller(.title2))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(width: size.frame.width, height: size.frame.height)
            }
        }
        .backport.glassEffect(.interactive(isEnabled: true))
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ProfilePictureComponent(size: .medium)
        .environment(appState)
}
