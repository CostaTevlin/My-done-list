// ConfettiView.swift
// Inlined from unionst/union-confetti.

import SwiftUI

/// Displays a confetti burst when `isPresented` is set to `true`.
/// Automatically resets `isPresented` to `false` after 5 seconds.
struct ConfettiView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @Binding var isPresented: Bool

    var body: some View {
        GeometryReader { proxy in
            ConfettiRepresentable(isPresented: $isPresented)
                .offset(y: -proxy.size.height / 2 - safeAreaInsets.top)
        }
        .edgesIgnoringSafeArea(.all)
        .allowsHitTesting(false)
    }
}
