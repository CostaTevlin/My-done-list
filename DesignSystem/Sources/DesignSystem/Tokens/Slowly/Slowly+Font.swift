// Slowly+Font.swift
// Slowly type ramp — token names match Figma exactly.
// Sources: node 17:2463 (display scale) + node 17:3265 (full ramp), 2026-05-22.
// Uses SF Pro / SF Pro Display via system font API (ADR-0004 superseded 2026-05-19).
// Dynamic Type: system fonts scale automatically.
// Line heights and tracking are Figma spec values — apply at call site via
//   .lineSpacing() and .tracking() when exact fidelity matters.
// Source of truth: Figma Slowly-MVP › Typography tokens.
// Phase: 4.5 · D1 token scaffolding

import SwiftUI

public extension Slowly {

    enum Font {

        // ── Hero ──────────────────────────────────────────────────────────────

        /// 130pt · Light · SF Pro Display · big counter on Today.
        /// Figma: "Slowly/bigNumeral" · lineHeight 1.0, letterSpacing 0.
        /// Apply .monospacedDigit() at call site.
        public static let bigNumeral: SwiftUI.Font = .system(size: 130, weight: .light, design: .default)

        // ── Display ───────────────────────────────────────────────────────────

        /// 60pt · Light · SF Pro Display · hero title.
        /// Figma: "Title Display" · lineHeight 1.0, letterSpacing 0.
        public static let titleDisplay: SwiftUI.Font = .system(size: 60, weight: .light, design: .default)

        /// 40pt · Light · SF Pro · page title.
        /// Figma: "Title 1 Light" · lineHeight 1.25, letterSpacing -0.1.
        public static let title1Light: SwiftUI.Font = .system(size: 40, weight: .light, design: .default)

        /// 30pt · Light · SF Pro · section heading / modal title.
        /// Figma: "Title 2 Light" · lineHeight 1.3, letterSpacing +0.2.
        public static let title2Light: SwiftUI.Font = .system(size: 30, weight: .light, design: .default)

        // ── Body ──────────────────────────────────────────────────────────────

        /// 18pt · Regular · primary headline copy.
        /// Figma: "Headline Regular" · lineHeight 24pt, letterSpacing -0.1.
        public static let headlineRegular: SwiftUI.Font = .system(size: 18, weight: .regular, design: .default)

        /// 16pt · Regular · primary body text, input fields.
        /// Figma: "Body Regular" · lineHeight 24pt, letterSpacing -0.2.
        public static let bodyRegular: SwiftUI.Font = .system(size: 16, weight: .regular, design: .default)

        /// 16pt · Medium · emphasized body text, interactive labels.
        /// Figma: "Body Medium" · lineHeight 24pt, letterSpacing -0.1.
        public static let bodyMedium: SwiftUI.Font = .system(size: 16, weight: .medium, design: .default)

        /// 13pt · Regular · supporting copy, subtitles.
        /// Figma: "Footnote Regular" · lineHeight 100% (proportional), letterSpacing 0.
        public static let footnoteRegular: SwiftUI.Font = .system(size: 13, weight: .regular, design: .default)

        // ── Footnote & Caption ────────────────────────────────────────────────

        /// 13pt · Medium · footnote emphasis.
        /// Figma: "Footnote Medium" · lineHeight 100% (proportional), letterSpacing 0.
        public static let footnoteMedium: SwiftUI.Font = .system(size: 13, weight: .medium, design: .default)


        /// 11pt · Regular · captions, timestamps.
        /// Figma: "Caption Regular" · lineHeight 100% (proportional), letterSpacing 0.
        public static let captionRegular: SwiftUI.Font = .system(size: 11, weight: .regular, design: .default)

        /// 11pt · Bold · caption strong emphasis.
        /// Figma: "Caption Bold" · lineHeight 100% (proportional), letterSpacing 0.
        public static let captionBold: SwiftUI.Font = .system(size: 11, weight: .bold, design: .default)
    }
}
