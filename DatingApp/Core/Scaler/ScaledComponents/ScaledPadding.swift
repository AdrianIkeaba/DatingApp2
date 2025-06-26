//
//  ScaledPadding.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//


import SwiftUI

struct ScaledPadding: ViewModifier {
    @Environment(\.scaler) private var scaler
    let edges: Edge.Set
    let value: CGFloat

    func body(content: Content) -> some View {
        content.padding(edges, scaler.w(value))
    }
}

extension View {
    func scaledPadding(_ edges: Edge.Set = .all, _ value: CGFloat) -> some View {
        self.modifier(ScaledPadding(edges: edges, value: value))
    }
}
