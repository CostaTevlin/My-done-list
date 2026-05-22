// Spacing.swift
// Slowly spacing scale — T-shirt sizes xs–3xl + screen-edge tokens.
// Values sourced from Figma Slowly-MVP spacing variables (node 1:3932).
// Use @ScaledMetric at the call site for any spacing that should grow with
//   Dynamic Type (e.g. row inner padding, icon-text gaps).
// Source of truth: Figma Slowly-MVP › spacing variables (node 1:3932).
// Phase: 4.5 · D1 token scaffolding

import CoreGraphics

public extension Slowly {

    enum Spacing {

        // ── T-shirt scale ─────────────────────────────────────────────────────
        /// 8pt — icon-text gaps, tight row padding.
        public static let xs: CGFloat = 8

        /// 12pt — row inner padding, compact stacks.
        public static let sm: CGFloat = 12

        /// 16pt — standard item row gap.
        public static let md: CGFloat = 16

        /// 20pt — section spacing, card inset.
        public static let lg: CGFloat = 20

        /// 24pt — modal vertical rhythm, grouped sections.
        public static let xl: CGFloat = 24

        /// 32pt — larger breathing room between major sections.
        public static let xxl: CGFloat = 32

        /// 40pt — section dividers, hero block clearance.
        public static let xxxl: CGFloat = 40

        // ── Screen-edge ───────────────────────────────────────────────────────
        /// 27pt — safe area from status bar / notch to first content.
        public static let screenTop: CGFloat = 27

        /// 62pt — safe area clearance at bottom (above tab bar / home indicator).
        public static let screenBottom: CGFloat = 62
    }
}
