//
//  ScalerInjector.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//


import SwiftUI

struct ScalerInjector: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .environment(\.scaler, Scaler(screenWidth: geo.size.width, screenHeight: geo.size.height))
        }
    }
}

extension View {
    func injectScaler() -> some View {
        self.modifier(ScalerInjector())
    }
}
