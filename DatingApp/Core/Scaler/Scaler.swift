//
//  Scaler.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//


import SwiftUI

struct Scaler {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    private let baseWidth: CGFloat = 375
    private let baseHeight: CGFloat = 812

    func w(_ value: CGFloat) -> CGFloat {
        (screenWidth / baseWidth) * value
    }

    func h(_ value: CGFloat) -> CGFloat {
        (screenHeight / baseHeight) * value
    }

    func f(_ size: CGFloat) -> CGFloat {
        min(w(size), h(size))
    }
}
