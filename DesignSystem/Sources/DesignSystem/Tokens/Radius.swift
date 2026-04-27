// Radius.swift
// Corner radii. Mirrors design-system/Tokens.md (Radius).
//
// Phase: 1
// See: design-system/Tokens.md (Radius)

import CoreGraphics

public enum Radius {
    /// Pill shapes — prefer `.clipShape(.capsule)` over hardcoding 9999.
    public static let pill: CGFloat = 9999

    /// 14pt — modal corners, chart bar corners
    public static let card: CGFloat = 14

    /// 8pt — small inline chips (unused in v1, reserved)
    public static let chip: CGFloat = 8
}
