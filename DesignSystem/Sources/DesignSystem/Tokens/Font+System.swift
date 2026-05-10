// Font+System.swift
// SF Pro Display type scale (Phase 5 — replaces Outfit).
// Uses SwiftUI system font API; SF Pro Display activates at large optical sizes automatically.
// Phase: 5 (supersedes Font+Outfit.swift, per ADR-0004 Status: Superseded)
// See: design-system/Tokens.md §Typography

import SwiftUI

public extension Font {
    /// 44pt · Regular · top page title
    static let display      = Font.system(size: 44, weight: .regular,  design: .default)
    /// 28pt · Regular · empty state heading / modal title
    static let displaySub   = Font.system(size: 28, weight: .regular,  design: .default)
    /// 96pt · Regular · the big counter (monospaced digits)
    static let bigNumeral   = Font.system(size: 96, weight: .regular,  design: .default).monospacedDigit()
    /// 17pt · Regular · body text
    static let body         = Font.system(size: 17, weight: .regular,  design: .default)
    /// 14pt · Regular · sub-copy
    static let bodySub      = Font.system(size: 14, weight: .regular,  design: .default)
    /// 17pt · Regular · rotating motivational copy
    static let motivational = Font.system(size: 17, weight: .regular,  design: .default)
    /// 10pt · Medium · zero-padded item rank
    static let num          = Font.system(size: 10, weight: .medium,   design: .default).monospacedDigit()
    /// 11pt · Regular · HH:mm timestamps
    static let time         = Font.system(size: 11, weight: .regular,  design: .default).monospacedDigit()
    /// 11pt · Medium · uppercase labels / greetings — pair with kerning(TypographyKerning.label)
    static let label        = Font.system(size: 11, weight: .medium,   design: .default)
    /// 13pt · Medium · count above each chart bar
    static let chartCount   = Font.system(size: 13, weight: .medium,   design: .default).monospacedDigit()
    /// 11pt · Regular · day labels under chart bars
    static let chartDayLabel = Font.system(size: 11, weight: .regular, design: .default)
}

/// Kerning constants — only .label survives the SF Pro migration.
/// All other Outfit kerning values are removed; SF Pro handles its own optical kerning.
public enum TypographyKerning {
    /// 0.88pt — uppercase labels need extra tracking in SF Pro
    public static let label: CGFloat = 0.88
}
