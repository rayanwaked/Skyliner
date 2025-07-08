//
//  NotificationComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/7/25.
//

// MARK: - IMPORTS
import SwiftUI

// MARK: - VIEW
struct NotificationComponent: View {
    // MARK: - VALUES
    let notification: NotificationModel
    
    // MARK: - Properties
    var body: some View {
        HStack(alignment: .top, spacing: PaddingConstants.smallPadding) {
            // Avatar
            AsyncImage(url: notification.author.avatar) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            
            VStack(alignment: .leading) {
                HStack(spacing: PaddingConstants.tinyPadding) {
                    Text(notification.author.displayName ?? notification.author.handle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(reasonText(for: notification.reason))
                        .font(.subheadline)
                    
                    Spacer()
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.indexedAt, style: .relative)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, PaddingConstants.defaultPadding)
        .padding(.vertical, 4)
        .background(
            notification.isRead ? Color.defaultBackground : Color.blue
                .opacity(0.05)
        )
        .cornerRadius(8)
    }
    
    // MARK: - Private Methods
    private func reasonText(for reason: NotificationModel.NotificationReason) -> String {
        switch reason {
        case .like:
            return "liked your post"
        case .repost:
            return "reposted your post"
        case .follow:
            return "followed you"
        case .mention:
            return "mentioned you"
        case .reply:
            return "replied to your post"
        case .quote:
            return "quoted your post"
        case .starterpackJoined:
            return "joined via starter pack"
        case .verified:
            return "verified"
        case .unverified:
            return "unverified"
        case .likeViaRepost:
            return "liked via repost"
        case .repostViaRepost:
            return "reposted via repost"
        case .subscribedPost:
            return "subscribed post"
        case .other:
            return "interacted with you"
        }
    }
}

#Preview {
    @Previewable @State var appState: AppState = .init()
    
    NotificationComponent(notification: NotificationModel.placeholders.first!)
        .environment(appState)
}
