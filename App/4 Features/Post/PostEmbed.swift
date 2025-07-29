//
//  PostEmbeds.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/5/25.
//

// MARK: - IMPORTS
import SwiftUI
import NukeUI
import ATProtoKit

// MARK: - POST EMBEDS VIEW
struct PostEmbed: View {
    @Environment(AppState.self) private var appState
    let embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?
    
    var body: some View {
        if let embed = embed {
            Group {
                switch embed {
                case .embedImagesView(let imagesEmbed):
                    MediaGrid(images: imagesEmbed.images)
                case .embedVideoView(let videoEmbed):
                    VideoThumbnail(video: videoEmbed)
                        .environment(appState)
                case .embedExternalView(let externalEmbed):
                    LinkPreview(external: externalEmbed.external)
                        .environment(appState)
                case .embedRecordView(let recordEmbed):
                    QuotedPost(record: recordEmbed.record)
                case .embedRecordWithMediaView(let recordWithMediaEmbed):
                    VStack(spacing: Padding.small) {
                        QuotedPost(record: recordWithMediaEmbed.record.record)
                        EmbedMedia(media: recordWithMediaEmbed.media)
                            .environment(appState)
                    }
                default:
                    EmptyView()
                }
            }
            .id(UUID())
        }
    }
}

// MARK: - MEDIA GRID
struct MediaGrid: View {
    let images: [AppBskyLexicon.Embed.ImagesDefinition.ViewImage]
    
    var body: some View {
        let columns = images.count == 1 ?
        [GridItem(.flexible())] :
        Array(repeating: GridItem(.flexible(), spacing: Padding.tiny), count: 2)
        
        LazyVGrid(columns: columns, spacing: Padding.tiny) {
            ForEach(images.indices, id: \.self) { index in
                AsyncImageView(url: images[index].fullSizeImageURL, altText: images[index].altText)
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: (Screen.width * 0.76)/CGFloat(images.count))
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: Radius.small / 3))
                    .backport.glassEffect(.tintedAndInteractive(
                        color: Color.blue.opacity(Opacity.soft),
                        isEnabled: true),
                                          in: RoundedRectangle(cornerRadius: Radius.small / 3)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
        .overlay(RoundedRectangle(cornerRadius: Radius.small).stroke(.primary.opacity(Opacity.soft)))
    }
}

// MARK: - ASYNC IMAGE VIEW
struct AsyncImageView: View {
    let url: URL?
    let altText: String?
    
    var body: some View {
        LazyImage(url: url) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.gray.opacity(Opacity.light))
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
        }
        .accessibilityLabel(altText ?? "")
    }
}

// MARK: - VIDEO THUMBNAIL
struct VideoThumbnail: View {
    @Environment(AppState.self) private var appState
    let video: AppBskyLexicon.Embed.VideoDefinition.View
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.small) {
            ZStack {
                AsyncImageView(url: video.thumbnailImageURL.flatMap(URL.init), altText: video.altText)
                    .frame(maxHeight: 200)
                    .aspectRatio(16/9, contentMode: .fit) // Add aspect ratio constraint
                
                Button {
                    if let altText = video.altText, !altText.isEmpty {
//                        appState.postManager.playVideo(from: video.cid)
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .background(.black.opacity(Opacity.standard), in: Circle())
                }
            }
            
            if let altText = video.altText, !altText.isEmpty {
                Text(altText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, Padding.small)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .fixedSize(horizontal: false, vertical: true) // Allow proper vertical sizing
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
        .overlay(RoundedRectangle(cornerRadius: Radius.small).stroke(.primary.opacity(Opacity.soft)))
        .backport.glassEffect(.tintedAndInteractive(
            color: Color.blue.opacity(Opacity.soft),
            isEnabled: true),
                              in: RoundedRectangle(cornerRadius: Radius.small)
        )
    }
}


// MARK: - LINK PREVIEW
struct LinkPreview: View {
    @Environment(AppState.self) private var appState
    let external: AppBskyLexicon.Embed.ExternalDefinition.ViewExternal
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail Image
            if let thumbnailURL = external.thumbnailImageURL {
                AsyncImageView(url: thumbnailURL, altText: nil)
                    .frame(maxHeight: Screen.height * 0.3)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            }
            
            // Content Section
            VStack(alignment: .leading) {
                // Title
                if !external.title.isEmpty {
                    Text(external.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Description
                if !external.description.isEmpty {
                    Text(external.description)
                        .font(.smaller(.subheadline))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 1)
                }
                
                // URL with domain extraction
                HStack(spacing: Padding.tiny) {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(appState.postManager.extractDomain(from: external.uri))
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                .padding(.top, Padding.tiny)
            }
            .padding(Padding.small)
        }
        .backport.glassEffect(.tintedAndInteractive(
            color: Color.blue.opacity(Opacity.soft),
            isEnabled: true),
                              in: RoundedRectangle(cornerRadius: Radius.small)
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
        .overlay(RoundedRectangle(cornerRadius: Radius.small).stroke(.primary.opacity(Opacity.soft)))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            Task {
                await appState.postManager.openExternalLink(external.uri)
            }
        }
        .onLongPressGesture(minimumDuration: 0) {
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Link preview: \(external.title)")
        .accessibilityHint("Double tap to open link")
    }
}

// MARK: - QUOTED POST
struct QuotedPost: View {
    let record: AppBskyLexicon.Embed.RecordDefinition.View.RecordViewUnion
    
    var body: some View {
        switch record {
        case .viewRecord(let viewRecord):
            QuotedPostContent(record: viewRecord)
        case .viewNotFound:
            PlaceholderView(icon: "exclamationmark.triangle", text: "Post not found", color: .orange)
        case .viewBlocked:
            PlaceholderView(icon: "hand.raised.fill", text: "Post blocked", color: .red)
        case .viewDetached:
            PlaceholderView(icon: "link.badge.plus", text: "Post detached", color: .gray)
        case .listView(let listView):
            SpecialRecordView(title: "List", subtitle: listView.name, description: listView.description, color: .green)
        case .labelerView(let labelerView):
            SpecialRecordView(title: "Labeler", subtitle: labelerView.creator.displayName ?? labelerView.creator.actorHandle, description: "", color: .purple)
        default:
            EmptyView()
        }
    }
}

// MARK: - QUOTED POST CONTENT
struct QuotedPostContent: View {
    let record: AppBskyLexicon.Embed.RecordDefinition.ViewRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.small) {
            HStack(alignment: .top, spacing: Padding.small) {
                AsyncImageView(url: record.author.avatarImageURL, altText: nil)
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(record.author.displayName ?? "")
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Text("@\(record.author.actorHandle)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(DateHelper.formattedRelativeDate(from: record.indexedAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if let postRecord = record.value.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
                Text(postRecord.text)
                    .font(.subheadline)
                    .lineLimit(6)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if let embeds = record.embeds, !embeds.isEmpty {
                VStack(spacing: Padding.small) {
                    ForEach(embeds.indices, id: \.self) { index in
                        NestedEmbed(embed: embeds[index])
                    }
                }
            }
        }
        .padding(Padding.small)
        .fixedSize(horizontal: false, vertical: true) // Allow proper vertical sizing
        .backport.glassEffect(.tintedAndInteractive(
            color: Color.blue.opacity(Opacity.soft),
            isEnabled: true),
                              in: RoundedRectangle(cornerRadius: Radius.small)
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
        .overlay(RoundedRectangle(cornerRadius: Radius.small).stroke(.primary.opacity(Opacity.soft)))
    }
}

// MARK: - NESTED EMBED
struct NestedEmbed: View {
    let embed: AppBskyLexicon.Embed.RecordDefinition.ViewRecord.EmbedsUnion
    
    var body: some View {
        switch embed {
        case .embedImagesView(let imagesView):
            MediaGrid(images: imagesView.images)
        case .embedVideoView(let videoView):
            VideoThumbnail(video: videoView)
        case .embedExternalView(let externalView):
            LinkPreview(external: externalView.external)
        default:
            EmptyView()
        }
    }
}

// MARK: - EMBED MEDIA HELPER
struct EmbedMedia: View {
    @Environment(AppState.self) private var appState
    let media: AppBskyLexicon.Embed.RecordWithMediaDefinition.View.MediaUnion
    
    var body: some View {
        switch media {
        case .embedImagesView(let imagesView):
            MediaGrid(images: imagesView.images)
        case .embedVideoView(let videoView):
            VideoThumbnail(video: videoView)
                .environment(appState)
        case .embedExternalView(let externalView):
            LinkPreview(external: externalView.external)
                .environment(appState)
        default:
            EmptyView()
        }
    }
}

// MARK: - PLACEHOLDER VIEW
struct PlaceholderView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Padding.small) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(Padding.standard)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true) // Allow proper vertical sizing
        .background(.gray.opacity(Opacity.soft))
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    }
}

// MARK: - SPECIAL RECORD VIEW
struct SpecialRecordView: View {
    let title: String
    let subtitle: String
    let description: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Padding.small) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
            if let description = description, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(Padding.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(Opacity.soft))
        .clipShape(RoundedRectangle(cornerRadius: Radius.small))
    }
}

// MARK: - PREVIEW
#Preview {
    @Previewable @State var appState: AppState = .init()
    
    ScrollView {
        PostFeature(location: .home)
            .environment(appState)
    }
}

