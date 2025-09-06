//
//  WebViewComponent.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/17/25.
//

import SwiftUI
import UIKit
import WebKit

// MARK: - VIEW
struct WebViewComponent: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}


// MARK: - PREVIEW
#Preview {
    WebViewComponent(url: URL(string: "https://bsky.social")!)
        .ignoresSafeArea(.all)
}
