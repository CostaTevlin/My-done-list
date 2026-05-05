// Color+Tokens.swift
// Brand color tokens. Single source of truth: design-system/Tokens.md.
// Light values ported verbatim from PWA index.html lines 28-100.
// Dark values are the Phase-9 proposal — to be validated on hardware.
//
// Phase: 1
// See: design-system/Tokens.md (Color)

import SwiftUI

public extension Color {
    /// Primary background. Light `#FFFFFF` · Dark `#000000` (OLED black)
    static let tokenWhite       = Color("tokenWhite", bundle: .module)

    /// Subtle secondary bg / card surface. Light `#FAFAFA` · Dark `#111111`
    static let tokenOffWhite    = Color("tokenOffWhite", bundle: .module)

    /// Divider lines / dashed borders. Light `#D1D1D1` · Dark `#333333`
    static let tokenBorder      = Color("tokenBorder", bundle: .module)

    /// Lighter dividers / row separators. Light `#E8E8E8` · Dark `#1C1C1C`
    static let tokenBorderLight = Color("tokenBorderLight", bundle: .module)

    /// Primary text + active UI + today bar. Light `#161A14` · Dark `#FFFFFF`
    static let tokenCharcoal    = Color("tokenCharcoal", bundle: .module)

    /// Secondary text + motivational copy. Light `#32373C` · Dark `#AAAAAA`
    static let tokenDark        = Color("tokenDark", bundle: .module)

    /// Tertiary text + metadata. Light `#8A8A87` · Dark `#666666`
    static let tokenMid         = Color("tokenMid", bundle: .module)

    /// Faint text + labels + timestamps. Light `#B8B8B5` · Dark `#484848`
    static let tokenLight       = Color("tokenLight", bundle: .module)

    /// Delete / destructive accent. Light `#CC4444` · Dark `#E66666`
    static let tokenDanger      = Color("tokenDanger", bundle: .module)
}
