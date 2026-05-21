// Font+Tokens.swift
// Slowly type ramp — 8 tokens mapped from Figma Slowly/* font variables.
// Uses SF Pro / SF Pro Display via system font API (ADR-0004 superseded 2026-05-19).
// Dynamic Type: system fonts scale automatically; no relativeTo: needed.
// Line heights and tracking are Figma spec values — apply at call site via
//   .lineSpacing() and .tracking() when exact fidelity matters.
// Source of truth: Figma Slowly-MVP › Slowly/* variables (node 1:3932).
// Phase: 4.5 · D1 token scaffolding

import SwiftUI

public extension Slowly {

    enum Font {

        // ── Display ───────────────────────────────────────────────────────────

        /// 130pt · Light · SF Pro Display · the big counter.
        /// Figma: lineHeight 1.0, letterSpacing 0.
        /// Apply .monospacedDigit() at call site when rendering numeric values.
        public static let bigNumeral: SwiftUI.Font = .system(size: 130, weight: .light, design: .default)

        /// 40pt · Light · top page title.
        /// Figma: lineHeight 1.25, letterSpacing -0.1.
        public static let display: SwiftUI.Font = .system(size: 40, weight: .light, design: .default)

        /// 30pt · Light · section heading / modal title.
        /// Figma: lineHeight 1.3, letterSpacing +0.2.
        public static let h2: SwiftUI.Font = .system(size: 30, weight: .light, design: .default)

        // ── Body ──────────────────────────────────────────────────────────────

        /// 18pt · Regular · rotating motivational copy above the ring.
        /// Figma: lineHeight 24pt, letterSpacing -0.1.
        public static let motivational: SwiftUI.Font = .system(size: 18, weight: .regular, design: .default)

        /// 16pt · Regular · primary body text, input fields.
        /// Figma: lineHeight 24pt, letterSpacing -0.2.
        public static let bodyText: SwiftUI.Font = .system(size: 16, weight: .regular, design: .default)

        /// 13pt · Regular · supporting copy, subtitles.
        /// Figma: lineHeight 100% (proportional), letterSpacing 0.
        public static let bodySub: SwiftUI.Font = .system(size: 13, weight: .regular, design: .default)

        // ── Utility ───────────────────────────────────────────────────────────

        /// 11pt · Regular · HH:mm timestamps.
        /// Figma: lineHeight 100% (proportional), letterSpacing 0.
        /// Apply .monospacedDigit() at call site.
        public static let time: SwiftUI.Font = .system(size: 11, weight: .regular, design: .default)

        /// 13pt · Medium · count above each chart bar.
        /// Figma: lineHeight 100% (proportional), letterSpacing 0.
        /// Apply .monospacedDigit() at call site.
        public static let chartCount: SwiftUI.Font = .system(size: 13, weight: .medium, design: .default)
    }
}
