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
                    VStack(spacing: 8) {
                        QuotedPost(record: recordWithMediaEmbed.record.record)
                        EmbedMedia(media: recordWithMediaEmbed.media)
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.top, PaddingConstants.tinyPadding)
        }
    }
}

// MARK: - MEDIA GRID
struct MediaGrid: View {
    let images: [AppBskyLexicon.Embed.ImagesDefinition.ViewImage]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: images.count == 1 ? 1 : 2), spacing: 4) {
            ForEach(images.indices, id: \.self) { index in
                AsyncImageView(url: images[index].fullSizeImageURL, altText: images[index].altText)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.primary.opacity(0.1)))
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
                    .frame(maxHeight: 300)
                    .clipped()
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.2))
                    .frame(height: 200)
            }
        }
        .accessibilityLabel(altText ?? "")
    }
}

// MARK: - VIDEO THUMBNAIL
struct VideoThumbnail: View {
    let video: AppBskyLexicon.Embed.VideoDefinition.View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                AsyncImageView(url: video.thumbnailImageURL.flatMap(URL.init), altText: video.altText)
                    .frame(maxHeight: 200)
                
                Button { /* TODO: Video playback */ } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .background(.black.opacity(0.3), in: Circle())
                }
            }
            
            if let altText = video.altText, !altText.isEmpty {
                Text(altText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.primary.opacity(0.1)))
    }
}

// MARK: - LINK PREVIEW
struct LinkPreview: View {
    let external: AppBskyLexicon.Embed.ExternalDefinition.ViewExternal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let thumbnailURL = external.thumbnailImageURL {
                AsyncImageView(url: thumbnailURL, altText: nil)
                    .frame(maxHeight: 150)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(external.title).font(.headline).lineLimit(2)
                Text(external.description).font(.subheadline).foregroundColor(.secondary).lineLimit(3)
                Text(external.uri).font(.caption).foregroundColor(.blue).lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.primary.opacity(0.1)))
        .onTapGesture {
            if let url = URL(string: external.uri) { UIApplication.shared.open(url) }
        }
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                AsyncImageView(url: record.author.avatarImageURL, altText: nil)
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(record.author.displayName ?? "").font(.caption).fontWeight(.medium).lineLimit(1)
                    Text("@\(record.author.actorHandle)").font(.caption2).foregroundColor(.secondary).lineLimit(1)
                }
                
                Spacer()
                Text(DateHelper.formattedRelativeDate(from: record.indexedAt)).font(.caption2).foregroundColor(.secondary)
            }
            
            if let postRecord = record.value.getRecord(ofType: AppBskyLexicon.Feed.PostRecord.self) {
                Text(postRecord.text).font(.subheadline).lineLimit(6)
            }
            
            if let embeds = record.embeds, !embeds.isEmpty {
                ForEach(embeds.indices, id: \.self) { index in
                    NestedEmbed(embed: embeds[index])
                }
            }
        }
        .padding(12)
        .background(.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.primary.opacity(0.1)))
    }
}

// MARK: - NESTED EMBED
struct NestedEmbed: View {
    let embed: AppBskyLexicon.Embed.RecordDefinition.ViewRecord.EmbedsUnion
    
    var body: some View {
        switch embed {
        case .embedImagesView(let imagesView): MediaGrid(images: imagesView.images)
        case .embedVideoView(let videoView): VideoThumbnail(video: videoView)
        case .embedExternalView(let externalView): LinkPreview(external: externalView.external)
        default: EmptyView()
        }
    }
}

// MARK: - EMBED MEDIA HELPER
struct EmbedMedia: View {
    let media: AppBskyLexicon.Embed.RecordWithMediaDefinition.View.MediaUnion
    
    var body: some View {
        switch media {
        case .embedImagesView(let imagesView): MediaGrid(images: imagesView.images)
        case .embedVideoView(let videoView): VideoThumbnail(video: videoView)
        case .embedExternalView(let externalView): LinkPreview(external: externalView.external)
        default: EmptyView()
        }
    }
}

// MARK: - PLACEHOLDER VIEW
struct PlaceholderView: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon).foregroundColor(color)
            Text(text).font(.subheadline).foregroundColor(.secondary)
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - SPECIAL RECORD VIEW
struct SpecialRecordView: View {
    let title: String
    let subtitle: String
    let description: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline)
            if let description = description {
                Text(description).font(.caption).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - PREVIEW
#Preview {
    PostEmbeds(embed: nil)
        .padding()
}
