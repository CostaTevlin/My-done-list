// Color+Tokens.swift
// Slowly-branded semantic color tokens.
// All values backed by asset catalog entries so dark-mode + Catalyst behave correctly.
// Source of truth: Figma Slowly-MVP › Color/* variables (node 1:3932).
// Phase: 4.5 · D1 token scaffolding

import SwiftUI

/// Top-level namespace for all Slowly-branded design tokens.
/// Access pattern: `Slowly.Color.textPrimary`, `Slowly.Spacing.md`, etc.
public enum Slowly {}

public extension Slowly {

    enum Color {

        // ── Text ─────────────────────────────────────────────────────────────
        /// #1c1c1e — primary body text, headlines, ring stroke at threshold.
        public static let textPrimary: SwiftUI.Color = SwiftUI.Color("slowlyTextPrimary", bundle: .module)

        /// #6b6b6b — secondary labels, timestamps, subtext.
        public static let textSecondary: SwiftUI.Color = SwiftUI.Color("slowlyTextSecondary", bundle: .module)

        // ── Surfaces ─────────────────────────────────────────────────────────
        /// #fafafa — app background, card surfaces.
        public static let surfaceApp: SwiftUI.Color = SwiftUI.Color("slowlySurfaceApp", bundle: .module)

        /// #F9F5F1 — warm cream ghost surface (Figma _bg-ghost).
        public static let surfaceGhost: SwiftUI.Color = SwiftUI.Color("slowlySurfaceGhost", bundle: .module)

        /// #ffffff — pure white, sheet backgrounds.
        public static let surfaceWhite: SwiftUI.Color = SwiftUI.Color("slowlySurfaceWhite", bundle: .module)

        // ── Borders ───────────────────────────────────────────────────────────
        /// #e8e9e6 — dividers, ring track, input stroke.
        public static let borderDefault: SwiftUI.Color = SwiftUI.Color("slowlyBorderDefault", bundle: .module)

        // ── Accent ────────────────────────────────────────────────────────────
        /// #4f8a61 — sage green primary CTA, active states, motivational text.
        public static let accentPrimary: SwiftUI.Color = SwiftUI.Color("slowlyAccentPrimary", bundle: .module)

        // ── Ring states ───────────────────────────────────────────────────────
        /// #dde7da — low-progress ring fill, reward halo.
        public static let ringLow: SwiftUI.Color = SwiftUI.Color("slowlyRingLow", bundle: .module)

        /// #a7c5a1 — mid-progress ring fill.
        public static let ringMid: SwiftUI.Color = SwiftUI.Color("slowlyRingMid", bundle: .module)

        /// #4f8a61 — ring at/over threshold (same hue as accentPrimary).
        public static let ringComplete: SwiftUI.Color = SwiftUI.Color("slowlyRingComplete", bundle: .module)

        // ── Actions ───────────────────────────────────────────────────────────
        /// #CC4444 — destructive action (swipe-to-delete only).
        public static let actionDestructive: SwiftUI.Color = SwiftUI.Color("slowlyActionDestructive", bundle: .module)
    }
}
