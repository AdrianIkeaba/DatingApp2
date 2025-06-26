//
//  ScaledText.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//


import SwiftUI

struct ScaledText: View {
    @Environment(\.scaler) private var scaler

    let content: String
    let size: CGFloat
    let fontName: String
    let color: Color
    let alignment: TextAlignment
    let lineLimit: Int?

    init(
        _ content: String,
        size: CGFloat,
        font: ProximaFont,
        color: Color = .primary,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil
    ) {
        self.content = content
        self.size = size
        self.fontName = font.rawValue
        self.color = color
        self.alignment = alignment
        self.lineLimit = lineLimit
    }


    var body: some View {
        Text(content)
            .font(.custom(fontName, size: scaler.f(size)))
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
    }
}


enum ProximaFont: String {
    case regular        = "ProximaNova-Regular"
    case italic         = "ProximaNova-RegularIt"
    case light          = "ProximaNova-Light"
    case semibold       = "ProximaNova-Semibold"
    case semiboldItalic = "ProximaNova-SemiboldIt"
    case bold           = "ProximaNova-Bold"
    case boldItalic     = "ProximaNova-BoldIt"
    case extraBold      = "ProximaNova-ExtraBold"
    case black          = "ProximaNova-Black"
    case blackItalic    = "ProximaNova-BlackIt"
}
