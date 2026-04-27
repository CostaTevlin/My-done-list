// BigNumeral.swift
// The hero counter on Today. 120pt Outfit ExtraLight, charcoal,
// -0.05em letter-spacing, with a smooth numeric content transition.
//
// Phase: 1 (placeholder), Phase 3 (wired to DoneStore)
// See: design-system/Components.md (BigNumeral)
//
// Note: #Preview blocks live in the app target's call sites, not here, so the
// SwiftPM package can compile without Xcode's Previews plugin.

import SwiftUI

public struct BigNumeral: View {
    public let value: Int

    public init(value: Int) {
        self.value = value
    }

    public var body: some View {
        Text(padded(value))
            .font(.tokenBigNumeral)
            .kerning(TypographyKerning.bigNumeral)
            .foregroundStyle(Color.tokenCharcoal)
            .contentTransition(.numericText())
            .accessibilityLabel("\(value) things logged today")
    }

    private func padded(_ n: Int) -> String {
        return n < 10 ? "0\(n)" : "\(n)"
    }
}
