//
//  BannerComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/3/25.
//

// MARK: - IMPORTS
import SwiftUI
import NukeUI
import Glur

// MARK: - VIEW
struct BannerComponent: View {
    // MARK: - VARIABLES
    var bannerURL: URL? = URL(string: "https://cdn.bsky.app/img/banner/plain/did:plc:fid77rvrx44chjgehhbpduun/bafkreidaqpiitbwjcd4ny3lvkuwetkoz5nrdt2brpdm2cpfkvt4xxbt4zm@jpeg")
    
    // MARK: - BODY
    var body: some View {
        VStack(spacing: 0) {
            if let bannerURL = bannerURL {
                LazyImage(url: bannerURL) { result in
                    result.image?
                        .resizable()
                        .clipShape(Rectangle())
                        .scaledToFill()
                }
            } else {
                Color.gray.frame(height: 120)
            }
            
            // Reflection
            ZStack(alignment: .top) {
                if let bannerURL = bannerURL {
                    LazyImage(url: bannerURL) { result in
                        result.image?
                            .resizable()
                            .glur(radius: 7, offset: 0.7, direction: .up)
                            .clipShape(Rectangle())
                            .scaledToFill()
                            .scaleEffect(x: 1, y: -1)
                    }
                } else {
                    Color.gray.frame(height: 120)
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    BannerComponent(bannerURL: URL(string: "https://cdn.bsky.app/img/banner/plain/did:plc:lkeohgqyet42i3ihmb4iuar6/bafkreiexoelyzolyaftn73z3m4ag3rfbnmayfb5gubxxewkwynqjyree4y@jpeg"))
}
