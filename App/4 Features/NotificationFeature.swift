//
//  NotificationFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/28/25.
//

import SwiftUI

// MARK: - VIEW
struct NotificationFeature: View {
    // MARK: - PROPERTIES
    @Environment(AppState.self) private var appState
    @Environment(RouterCoordinator.self) private var routerCoordinator
    
    // MARK: - BODY
    var body: some View {
        let notificationList = appState.notificationsManager.notifications
        if !notificationList.isEmpty {
            LazyVStack {
                ForEach(notificationList) { notification in
                    VStack {
                        HStack(spacing: 0) {
                            ProfilePictureComponent(
                                isUser: false,
                                profilePictureURL: notification.authorPictureURL
                            )
                            .onTapGesture {
                                withAnimation(.bouncy(duration: 0.5)) {
                                    appState.profileManager.userDID = notification.authorDID
                                    routerCoordinator.showingProfile = true
                                }
                                
                                hapticFeedback(.light)
                            }
                            .padding(.trailing, Padding.small)
                            
                            Text(" \(notification.authorName)")
                            Text(" \(notification.reason)")
                            
                            Spacer()
                            
                            Text(
                                DateHelper
                                    .formattedRelativeDate(
                                        from: notification.timestamp
                                    )
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Padding.standard)
                        .padding(.vertical, Padding.tiny)
                        
//                        Text("\(notification.content)")
//                            .padding(.leading, Padding.standard + Padding.tiny)
                    }
                    .padding(.bottom, Padding.tiny)
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    @Previewable @State var routerCoordinator: RouterCoordinator = .init()
    
    NotificationFeature()
        .environment(appState)
        .environment(routerCoordinator)
}

