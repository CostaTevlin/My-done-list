// PillButton.swift
// The brand pill — charcoal capsule, white text. Used as fallback on iOS 18-25
// and as the visual basis for `.buttonStyle(.glass)` on iOS 26.
//
// Phase: 1
// See: design-system/Components.md (PillButton)  ·  design-system/Liquid Glass mapping.md

import SwiftUI

public struct PillButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.tokenBody.weight(.medium))
            .foregroundStyle(Color.tokenWhite)
            .padding(.horizontal, Spacing.xl + 4)   // 28
            .padding(.vertical, Spacing.md + 2)     // 14
            .background(
                Capsule()
                    .fill(Color.tokenCharcoal.opacity(configuration.isPressed ? 0.85 : 1.0))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Motion.snappy, value: configuration.isPressed)
    }
}

public extension View {
    /// Brand pill that auto-upgrades to `.buttonStyle(.glass)` on iOS 26
    /// while keeping the charcoal `PillButtonStyle` on iOS 18-25.
    ///
    /// On non-iOS host builds (macOS during `swift build` verification) we
    /// always use the fallback — `.glass` is iOS-26-only.
    @ViewBuilder
    func brandPillStyle() -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass).tint(Color.tokenCharcoal)
        } else {
            self.buttonStyle(PillButtonStyle())
        }
        #else
        self.buttonStyle(PillButtonStyle())
        #endif
    }
}
