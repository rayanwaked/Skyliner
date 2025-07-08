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
struct PostEmbeds: View {
    let embed: AppBskyLexicon.Feed.PostViewDefinition.EmbedUnion?
    
    var body: some View {
        if let embed = embed {
            Group {
                switch embed {
                case .embedImagesView(let imagesEmbed):
                    MediaGrid(images: imagesEmbed.images)
                case .embedVideoView(let videoEmbed):
                    VideoThumbnail(video: videoEmbed)
                case .embedExternalView(let externalEmbed):
                    LinkPreview(external: externalEmbed.external)
                case .embedRecordView(let recordEmbed):
                    QuotedPost(record: recordEmbed.record)
                case .embedRecordWithMediaView(let recordWithMediaEmbed):
                    VStack(spacing: PaddingConstants.smallPadding) {
                        QuotedPost(record: recordWithMediaEmbed.record.record)
                        EmbedMedia(media: recordWithMediaEmbed.media)
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - MEDIA GRID
struct MediaGrid: View {
    let images: [AppBskyLexicon.Embed.ImagesDefinition.ViewImage]
    
    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: PaddingConstants.tinyPadding), count: images.count == 1 ? 1 : 2)
        
        LazyVGrid(columns: columns, spacing: PaddingConstants.tinyPadding) {
            ForEach(images.indices, id: \.self) { index in
                AsyncImageView(url: images[index].fullSizeImageURL, altText: images[index].altText)
                    .aspectRatio(images.count == 1 ? nil : 1, contentMode: .fill)
                    .frame(maxHeight: images.count == 1 ? 400 : 200) // Add explicit max height
            }
        }
        .fixedSize(horizontal: false, vertical: true) // Important: Let the grid size itself
        .clipShape(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius))
        .overlay(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius).stroke(.primary.opacity(ColorConstants.softOpaque)))
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
                    .clipped()
            } else {
                Rectangle()
                    .fill(.gray.opacity(ColorConstants.lightOpaque))
                    .frame(minHeight: 200) // Use minHeight instead of height
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
    let video: AppBskyLexicon.Embed.VideoDefinition.View
    
    var body: some View {
        VStack(alignment: .leading, spacing: PaddingConstants.smallPadding) {
            ZStack {
                AsyncImageView(url: video.thumbnailImageURL.flatMap(URL.init), altText: video.altText)
                    .frame(maxHeight: 200)
                    .aspectRatio(16/9, contentMode: .fit) // Add aspect ratio constraint
                
                Button { /* TODO: Video playback */ } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .background(.black.opacity(ColorConstants.defaultOpaque), in: Circle())
                }
            }
            
            if let altText = video.altText, !altText.isEmpty {
                Text(altText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, PaddingConstants.smallPadding)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .fixedSize(horizontal: false, vertical: true) // Allow proper vertical sizing
        .clipShape(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius))
        .overlay(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius).stroke(.primary.opacity(ColorConstants.softOpaque)))
    }
}

// MARK: - LINK PREVIEW
struct LinkPreview: View {
    let external: AppBskyLexicon.Embed.ExternalDefinition.ViewExternal
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail Image
            if let thumbnailURL = external.thumbnailImageURL {
                AsyncImageView(url: thumbnailURL, altText: nil)
                    .frame(maxHeight: 200)
                    .aspectRatio(contentMode: .fit)
                    .clipped()
            }
            
            // Content Section
            VStack(alignment: .leading, spacing: PaddingConstants.smallPadding) {
                // Title
                if !external.title.isEmpty {
                    Text(external.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Description
                if !external.description.isEmpty {
                    Text(external.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // URL with domain extraction
                HStack(spacing: PaddingConstants.tinyPadding) {
                    Image(systemName: "link")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(extractDomain(from: external.uri))
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: "arrow.up.right")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            .padding(PaddingConstants.smallPadding)
        }
        .background(.blue.opacity(ColorConstants.softOpaque))
        .clipShape(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius))
        .overlay(
            RoundedRectangle(cornerRadius: RadiusConstants.smallRadius)
                .stroke(.primary.opacity(ColorConstants.softOpaque))
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            if let url = URL(string: external.uri) {
                UIApplication.shared.open(url)
            }
        }
        .onLongPressGesture(minimumDuration: 0) {
            // Handle press state for visual feedback
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Link preview: \(external.title)")
        .accessibilityHint("Double tap to open link")
    }
    
    // Helper function to extract domain from URL
    private func extractDomain(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return urlString
        }
        
        // Remove www. prefix if present
        if host.hasPrefix("www.") {
            return String(host.dropFirst(4))
        }
        
        return host
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
        VStack(alignment: .leading, spacing: PaddingConstants.smallPadding) {
            HStack(spacing: PaddingConstants.smallPadding) {
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
                VStack(spacing: PaddingConstants.smallPadding) {
                    ForEach(embeds.indices, id: \.self) { index in
                        NestedEmbed(embed: embeds[index])
                    }
                }
            }
        }
        .padding(PaddingConstants.smallPadding)
        .fixedSize(horizontal: false, vertical: true) // Allow proper vertical sizing
        .background(.gray.opacity(ColorConstants.defaultOpaque))
        .clipShape(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius))
        .overlay(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius).stroke(.primary.opacity(ColorConstants.softOpaque)))
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
    let media: AppBskyLexicon.Embed.RecordWithMediaDefinition.View.MediaUnion
    
    var body: some View {
        switch media {
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

// MARK: - PLACEHOLDER VIEW
struct PlaceholderView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack(spacing: PaddingConstants.smallPadding) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(PaddingConstants.defaultPadding)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true) // Allow proper vertical sizing
        .background(.gray.opacity(ColorConstants.softOpaque))
        .clipShape(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius))
    }
}

// MARK: - SPECIAL RECORD VIEW
struct SpecialRecordView: View {
    let title: String
    let subtitle: String
    let description: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: PaddingConstants.smallPadding) {
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
        .padding(PaddingConstants.smallPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(ColorConstants.softOpaque))
        .clipShape(RoundedRectangle(cornerRadius: RadiusConstants.smallRadius))
    }
}

// MARK: - PREVIEW
#Preview {
    PostEmbeds(embed: nil)
        .padding()
}
