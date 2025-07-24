//
//  WeatherFeature.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/22/25.
//

import SwiftUI

struct WeatherFeature: View {
    var body: some View {
        ZStack {
            SplashDesign()

            VStack(spacing: 2) {
                Text("Portland")
                    .font(.smaller(.body))
                Text("30°")
                    .font(.system(size: 42))
                Text("Party Cloudy")
                    .font(.smaller(.callout))
                    .foregroundStyle(.secondary)
                Text("H:40° L:20°")
                    .font(.smaller(.body))
            }
            .foregroundStyle(.white)
            .padding(Padding.standard)
        }
        .frame(maxHeight: Screen.height * 0.2, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: Radius.standard))
        .backport.glassEffect(in: RoundedRectangle(cornerRadius: Radius.standard))
        .shadow(color: .gray, radius: 1)
        .padding(.horizontal, Padding.standard)
        .padding(.top, Screen.height * 0.065)
    }
}

#Preview {
    WeatherFeature()
}
