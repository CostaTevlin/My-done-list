// Color+Tokens.swift
// Semantic color tokens — public API for feature code and DesignSystem components.
// Each token aliases a primitive from Color+Palette.swift (internal).
// Source of truth: design-system/Tokens.md §Color › Semantic.
// Phase: 5 (two-tier refactor, replaces flat tokenX naming)

import SwiftUI

public extension Color {

    // ── Text ──────────────────────────────────────────────────────────────────

    /// Primary text, headlines, ring stroke at threshold. → palette neutral/900
    static let textPrimary       = Color.paletteNeutral900

    /// Secondary text, supporting labels, subtext. → palette neutral/500
    static let textSecondary     = Color.paletteNeutral500

    // ── Borders & surfaces ────────────────────────────────────────────────────

    /// Dividers, ring track, soft surfaces. → palette neutral/100
    static let borderDefault     = Color.paletteNeutral100

    /// App background, card surfaces. → palette neutral/50
    static let surfaceApp        = Color.paletteNeutral50

    // ── Accent ────────────────────────────────────────────────────────────────

    /// Primary accent — CTA, active states, motivational text. → palette sage/600
    static let accentPrimary     = Color.paletteSage600

    // ── Ring states ───────────────────────────────────────────────────────────

    /// Low-progress ring fill, reward halo. → palette sage/50
    static let ringLow           = Color.paletteSage50

    /// Mid-progress ring fill. → palette sage/300
    static let ringMid           = Color.paletteSage300

    /// Ring at/over threshold. → palette sage/600 (same hue as accentPrimary)
    static let ringComplete      = Color.paletteSage600

    // ── Actions ───────────────────────────────────────────────────────────────

    /// Destructive — swipe-to-delete only. → palette red/500
    static let actionDestructive = Color.paletteRed500
}
