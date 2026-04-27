// Spacing.swift
// Spacing scale. Mirrors design-system/Tokens.md (Spacing).
//
// Phase: 1
// See: design-system/Tokens.md (Spacing)

import CoreGraphics

public enum Spacing {
    /// 4pt — tight icon-text gaps
    public static let xs: CGFloat = 4

    /// 8pt — row inner padding
    public static let sm: CGFloat = 8

    /// 12pt — item row gap
    public static let md: CGFloat = 12

    /// 16pt — section spacing
    public static let lg: CGFloat = 16

    /// 24pt — modal vertical rhythm
    public static let xl: CGFloat = 24

    /// 28pt — screen horizontal padding (`max(28, safe-area-inset)`)
    public static let xxl: CGFloat = 28

    /// 40pt — section dividers
    public static let xxxl: CGFloat = 40

    /// 100pt — reserved for tab bar + accessory pill clearance
    public static let bottomSafe: CGFloat = 100
}
