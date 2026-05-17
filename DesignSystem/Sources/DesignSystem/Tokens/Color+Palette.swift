// Color+Palette.swift
// Primitive color palette — internal to the DesignSystem package.
// Source of truth: design-system/Tokens.md §Color › Palette.
// Do NOT use these in feature code. Consume semantic tokens from Color+Tokens.swift.
// Phase: 5 (two-tier refactor)

import SwiftUI

extension Color {
    // Sage scale
    static let paletteSage50    = Color("paletteSage50",     bundle: .module)
    static let paletteSage300   = Color("paletteSage300",    bundle: .module)
    static let paletteSage600   = Color("paletteSage600",    bundle: .module)

    // Neutral scale
    static let paletteNeutral50  = Color("paletteNeutral50",  bundle: .module)
    static let paletteNeutral100 = Color("paletteNeutral100", bundle: .module)
    static let paletteNeutral500 = Color("paletteNeutral500", bundle: .module)
    static let paletteNeutral900 = Color("paletteNeutral900", bundle: .module)

    // Red scale
    static let paletteRed500    = Color("paletteRed500",     bundle: .module)
}
