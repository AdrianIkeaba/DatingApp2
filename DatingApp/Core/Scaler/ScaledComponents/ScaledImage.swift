//
//  ScaledImage.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//


import SwiftUI

struct ScaledImage: View {
    @Environment(\.scaler) private var scaler

    let name: String
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat

    init(_ name: String, width: CGFloat, height: CGFloat, cornerRadius: CGFloat = 0) {
        self.name = name
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: scaler.w(width), height: scaler.h(height))
            .cornerRadius(scaler.w(cornerRadius))
    }
}
