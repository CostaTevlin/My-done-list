// Color+Tokens.swift
// Brand color tokens — sage palette (Phase 5 migration from charcoal).
// Source of truth: design-system/Tokens.md §Color.
// Phase: 5 (replaces Phase 1 charcoal palette)

import SwiftUI

public extension Color {
    /// Primary text, headlines, ring stroke at threshold. Light #1C1C1E · Dark #F2F2F2
    static let tokenInk     = Color("tokenInk",     bundle: .module)

    /// Secondary text, supporting labels, subtext. Light #6B6B6B · Dark #9A9A9A
    static let tokenSlate   = Color("tokenSlate",   bundle: .module)

    /// Dividers, ring track, soft surfaces. Light #E8E9E6 · Dark #2A2A2A
    static let tokenMist    = Color("tokenMist",    bundle: .module)

    /// Low-progress ring fill, reward halo. Light #DDE7DA · Dark #1F2A22
    static let tokenSage50  = Color("tokenSage50",  bundle: .module)

    /// Mid-progress ring fill. Light #A7C5A1 · Dark #5C8466
    static let tokenSage300 = Color("tokenSage300", bundle: .module)

    /// Ring at/over threshold, primary accent. Light #4F8A61 · Dark #7CB089
    static let tokenSage600 = Color("tokenSage600", bundle: .module)

    /// App background, card surfaces. Light #FAFAFA · Dark #0E1110
    static let tokenSurface = Color("tokenSurface", bundle: .module)

    /// Destructive (swipe-to-delete only). Light #CC4444 · Dark #E66666
    static let tokenDanger  = Color("tokenDanger",  bundle: .module)
}
