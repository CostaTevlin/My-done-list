// Slowly+Radii.swift
// Slowly corner radius tokens.
// Source of truth: Figma Slowly-MVP › radius variables (confirmed 2026-05-21).
// Phase: 4.5 · D1 token scaffolding

import CoreGraphics

public extension Slowly {

    enum Radius {
        /// 20pt — card and list-item corners.
        public static let card: CGFloat = 20

        /// 32pt — button (PillButton / CTA) corners.
        public static let button: CGFloat = 32

        /// 40pt — bottom sheet top corners.
        public static let sheet: CGFloat = 40

        /// 9999pt — FAB; prefer `.clipShape(.capsule)` over this constant.
        public static let fab: CGFloat = 9999

        // TODO: add ringInset once Figma defines Slowly/radius/ringInset.
        /// Inner ring inset corner radius. TBD — not yet in Figma.
        public static let ringInset: CGFloat = 0
    }
}
