//
//  ScalerKey.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//


import SwiftUI

private struct ScalerKey: EnvironmentKey {
    static let defaultValue = Scaler(screenWidth: 375, screenHeight: 812)
}

extension EnvironmentValues {
    var scaler: Scaler {
        get { self[ScalerKey.self] }
        set { self[ScalerKey.self] = newValue }
    }
}
