// Font+Outfit.swift
// Outfit type scale. Mirrors design-system/Tokens.md typography table.
//
// The fonts must be registered in the app target's Info.plist UIAppFonts array
// AND the .ttf files must be added to the app's bundle. The DesignSystem
// package only declares the Font references — registration happens in the app.
//
// Phase: 1
// See: design-system/Tokens.md (Typography)  ·  decisions/0004 — Outfit OFL 1.1

import SwiftUI

public extension Font {
    /// Returns an Outfit font at the given size + weight. Falls back to system
    /// regular if a weight outside Outfit's shipped 5 cuts is requested.
    static func outfit(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .ultraLight, .thin:           name = "Outfit-ExtraLight"  // 200
        case .light:                       name = "Outfit-Light"       // 300
        case .regular:                     name = "Outfit-Regular"     // 400
        case .medium:                      name = "Outfit-Medium"      // 500
        case .semibold, .bold,
             .heavy, .black:               name = "Outfit-SemiBold"    // 600
        default:                           name = "Outfit-Regular"
        }
        return .custom(name, size: size)
    }

    // MARK: - Named tokens (mirrors Tokens.md type scale)

    /// 44pt · 200 · -0.05em kerning · top page title
    static let tokenDisplay       = Font.outfit(44, .ultraLight)

    /// 28pt · 300 · -0.03em · empty state heading / modal title
    static let tokenDisplaySub    = Font.outfit(28, .light)

    /// 120pt · 200 · -0.05em · the big counter
    static let tokenBigNumeral    = Font.outfit(120, .ultraLight)

    /// 17pt · 400 · -0.01em · body text
    static let tokenBody          = Font.outfit(17, .regular)

    /// 14pt · 400 · -0.01em · sub-copy
    static let tokenBodySub       = Font.outfit(14, .regular)

    /// 17pt · 300 · -0.01em · rotating motivational copy
    static let tokenMotivational  = Font.outfit(17, .light)

    /// 10pt · 500 · zero-padded item rank
    static let tokenNum           = Font.outfit(10, .medium).monospacedDigit()

    /// 11pt · 400 · HH:mm timestamps
    static let tokenTime          = Font.outfit(11, .regular).monospacedDigit()

    /// 11pt · 500 · 0.08em · uppercase labels / greetings
    static let tokenLabel         = Font.outfit(11, .medium)

    /// 13pt · 500 · count above each chart bar
    static let tokenChartCount    = Font.outfit(13, .medium).monospacedDigit()

    /// 11pt · 400 · day labels under chart bars
    static let tokenChartDayLabel = Font.outfit(11, .regular)
}

/// Suggested kerning per token. Apply via `.kerning(.tokenDisplay)` at the call site —
/// SwiftUI does not bake kerning into `Font` itself.
public enum TypographyKerning {
    public static let display: CGFloat       = -2.2
    public static let displaySub: CGFloat    = -0.84
    public static let bigNumeral: CGFloat    = -6.0
    public static let body: CGFloat          = -0.17
    public static let motivational: CGFloat  = -0.17
    public static let label: CGFloat         = 0.88
}

/// Line-height helpers via `.lineSpacing()` — values from Tokens.md.
public enum TypographyLineHeight {
    public static let display: CGFloat       = 0.9    // multiplier
    public static let bigNumeral: CGFloat    = 0.82
    public static let body: CGFloat          = 1.45
    public static let motivational: CGFloat  = 1.5
}
