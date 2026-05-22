// Slowly+Color.swift
// Slowly-branded semantic color tokens.
// All values backed by asset catalog entries so dark-mode + Catalyst behave correctly.
// Token names match Figma exactly — nodes 17:2463 + 17:3265 (2026-05-22).
// Source of truth: Figma Slowly-MVP › Color/*, Neutral/*, Sage/* variables.
// Phase: 4.5 · D1 token scaffolding

import SwiftUI

/// Top-level namespace for all Slowly-branded design tokens.
/// Access pattern: `Slowly.Color.textPrimary`, `Slowly.Spacing.md`, etc.
public enum Slowly {}

public extension Slowly {

    enum Color {

        // ── Text ──────────────────────────────────────────────────────────────

        /// #1c1c1e — primary body text, headlines, ring stroke at threshold.
        /// Figma: "Color/Text/Primary"
        public static let textPrimary: SwiftUI.Color = SwiftUI.Color("slowlyTextPrimary", bundle: .module)

        /// #6b6b6b — secondary labels, timestamps, subtext.
        /// Figma: "Color/Text/Secondary"
        public static let textSecondary: SwiftUI.Color = SwiftUI.Color("slowlyTextSecondary", bundle: .module)

        /// #ffffff — primary text on dark/coloured backgrounds.
        /// Figma: "Color/Text/PrimaryWhite"
        public static let textPrimaryWhite: SwiftUI.Color = SwiftUI.Color("slowlyTextPrimaryWhite", bundle: .module)

        /// #ffffff 80% — secondary text on dark/coloured backgrounds.
        /// Figma: "Color/Text/SecondaryWhite"
        public static let textSecondaryWhite: SwiftUI.Color = SwiftUI.Color("slowlyTextSecondaryWhite", bundle: .module)

        // ── Surfaces ──────────────────────────────────────────────────────────

        /// #fafafa — app background, card surfaces.
        /// Figma: "Color/Surface/App"
        public static let surfaceApp: SwiftUI.Color = SwiftUI.Color("slowlySurfaceApp", bundle: .module)

        /// #F9F5F1 — warm cream ghost surface.
        /// Figma: "_bg-ghost" (node 1:3932 — not present at 17:2463/17:3265, retained).
        public static let surfaceGhost: SwiftUI.Color = SwiftUI.Color("slowlySurfaceGhost", bundle: .module)

        // ── Borders ───────────────────────────────────────────────────────────

        /// #e8e9e6 — dividers, ring track, input stroke.
        /// Figma: "Color/Border/Default"
        public static let borderDefault: SwiftUI.Color = SwiftUI.Color("slowlyBorderDefault", bundle: .module)

        // ── Accent ────────────────────────────────────────────────────────────

        /// #4f8a61 — sage green primary CTA, active states.
        /// Figma: "Color/Accent/Primary"
        public static let accentPrimary: SwiftUI.Color = SwiftUI.Color("slowlyAccentPrimary", bundle: .module)

        // ── Ring states ───────────────────────────────────────────────────────

        /// #dde7da — low-progress ring fill, reward halo.
        /// Figma: "Color/Ring/Low"
        public static let ringLow: SwiftUI.Color = SwiftUI.Color("slowlyRingLow", bundle: .module)

        /// #a7c5a1 — mid-progress ring fill.
        /// Figma: "Color/Ring/Mid"
        public static let ringMid: SwiftUI.Color = SwiftUI.Color("slowlyRingMid", bundle: .module)

        /// #4f8a61 — ring at/over threshold (same hue as accentPrimary).
        /// Figma: "Color/Ring/Complete"
        public static let ringComplete: SwiftUI.Color = SwiftUI.Color("slowlyRingComplete", bundle: .module)

        // ── Primitives ────────────────────────────────────────────────────────

        /// #fafafa — neutral primitive (same value as surfaceApp).
        /// Figma: "Neutral/50"
        public static let neutral50: SwiftUI.Color = SwiftUI.Color("slowlyNeutral50", bundle: .module)

        /// #dde7da — sage primitive (same value as ringLow).
        /// Figma: "Sage/50"
        public static let sage50: SwiftUI.Color = SwiftUI.Color("slowlySage50", bundle: .module)

        // ── Actions ───────────────────────────────────────────────────────────

        /// #CC4444 — destructive action (swipe-to-delete only).
        /// Not present at nodes 17:2463/17:3265 — retained pending Figma confirmation.
        public static let actionDestructive: SwiftUI.Color = SwiftUI.Color("slowlyActionDestructive", bundle: .module)
    }
}
