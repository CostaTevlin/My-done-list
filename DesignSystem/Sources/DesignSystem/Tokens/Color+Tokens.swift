// Color+Tokens.swift
// Brand color tokens. Single source of truth: design-system/Tokens.md.
// Light values ported verbatim from PWA index.html lines 28-100.
// Dark values are the Phase-9 proposal — to be validated on hardware.
//
// Phase: 1
// See: design-system/Tokens.md (Color)

import SwiftUI

public extension Color {
    /// Primary background. Light `#FFFFFF` · Dark `#0E1110`
    static let tokenWhite       = Color("tokenWhite", bundle: .module)

    /// Subtle secondary bg / empty state. Light `#FAFAFA` · Dark `#171A18`
    static let tokenOffWhite    = Color("tokenOffWhite", bundle: .module)

    /// Divider lines / item separators. Light `#D1D1D1` · Dark `#2A2D2A`
    static let tokenBorder      = Color("tokenBorder", bundle: .module)

    /// Lighter dividers / tab bar border. Light `#E8E8E8` · Dark `#1F2220`
    static let tokenBorderLight = Color("tokenBorderLight", bundle: .module)

    /// Primary text + active UI + today bar. Light `#161A14` · Dark `#F5F5F2`
    static let tokenCharcoal    = Color("tokenCharcoal", bundle: .module)

    /// Secondary text + motivational copy. Light `#32373C` · Dark `#C9CCC4`
    static let tokenDark        = Color("tokenDark", bundle: .module)

    /// Tertiary text + metadata. Light `#8A8A87` · Dark `#7A7A77`
    static let tokenMid         = Color("tokenMid", bundle: .module)

    /// Faint text + labels + timestamps. Light `#B8B8B5` · Dark `#5A5A57`
    static let tokenLight       = Color("tokenLight", bundle: .module)

    /// Delete / destructive accent. Light `#CC4444` · Dark `#E66666`
    static let tokenDanger      = Color("tokenDanger", bundle: .module)
}
