//
//  ScaledSpacer.swift
//  DatingApp
//
//  Created by GHØβT on 25/06/2025.
//


import SwiftUI

struct ScaledSpacer: View {
    @Environment(\.scaler) private var scaler
    let height: CGFloat

    var body: some View {
        Spacer().frame(height: scaler.h(height))
    }
}
