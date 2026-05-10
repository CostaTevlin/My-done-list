// PillButton.swift
// The brand pill — tokenInk capsule, tokenSurface text. Used as fallback on iOS 18-25
// and as the visual basis for `.buttonStyle(.glass)` on iOS 26.
//
// Phase: 5 (token migration to sage palette)
// See: design-system/Components.md (PillButton)  ·  design-system/Liquid Glass mapping.md

import SwiftUI

public struct PillButtonStyle: ButtonStyle {
    @Environment((\.colorScheme)) private var colorScheme
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .foregroundStyle(colorScheme == .dark ? Color.tokenInk : Color.tokenSurface)
            .padding(.horizontal, Spacing.xl + 4)   // 28
            .padding(.vertical, Spacing.md + 2)     // 14
            .background(pillBackground(isPressed: configuration.isPressed))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Motion.snappy, value: configuration.isPressed)
    }

    @ViewBuilder
    private func pillBackground(isPressed: Bool) -> some View {
        if colorScheme == .dark {
            // Endel-style: tokenInk stroke ring, transparent fill
            Capsule()
                .strokeBorder(Color.tokenInk.opacity(isPressed ? 0.5 : 1.0), lineWidth: 1.5)
        } else {
            Capsule()
                .fill(Color.tokenInk.opacity(isPressed ? 0.85 : 1.0))
        }
    }
}

public extension View {
    /// Brand pill that auto-upgrades to `.buttonStyle(.glassProminent)` on
    /// iOS 26 (filled glass — the tint color carries the brand) while keeping
    /// the tokenInk `PillButtonStyle` on iOS 18-25.
    ///
    /// `.glass` (clear) was tried first, but on the app's white surfaces it
    /// renders nearly invisible — clear glass needs something colorful to
    /// refract. `.glassProminent` keeps the Liquid Glass material treatment
    /// (inner highlight, edge sheen) while filling with `tokenInk`, so
    /// the CTA reads with the same visual weight as the iOS 18-25 pill.
    ///
    /// On non-iOS host builds (macOS during `swift build` verification) we
    /// always use the fallback — glass styles are iOS-26-only.
    ///
    /// Note: the raw hex #161A14 is used for the iOS 26 tint to keep
    /// charcoal-dark value stable regardless of color scheme resolution
    /// (tokenInk resolves to white in dark mode, which would invert the pill).
    @ViewBuilder
    func brandPillStyle() -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            // Always tint with the raw ink value — tokenInk resolves
            // to white in dark mode, which would invert the pill unintentionally.
            self.buttonStyle(.glassProminent).tint(Color(red: 22/255, green: 26/255, blue: 20/255))
        } else {
            self.buttonStyle(PillButtonStyle())
        }
        #else
        self.buttonStyle(PillButtonStyle())
        #endif
    }
}
