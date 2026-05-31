// HapticEngine.swift
// Gentle-only haptic feedback. Honors the Settings haptic toggle and the
// system Reduce Motion preference (passed in by the caller — `@Environment`
// values can't be read from a free function).
//
// Phase: 4
// See: decisions/0006 — Confetti (haptic always gentle)

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum HapticEngine {

    /// `@AppStorage` key for the user-facing haptic toggle in Settings.
    /// Phase 6 surfaces the toggle UI; we already gate playback on it now so
    /// the contract is stable.
    static let settingsKey = "hapticsEnabled"

    /// Light, success-flavored tap. Used on log submit alongside the confetti
    /// variant. Always gentle — ADR-0006 forbids `.heavy` / `.rigid` / `.warning`.
    static func success(reduceMotion: Bool = false) {
        guard isEnabled, !reduceMotion else { return }
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    /// Subtler than `success` — used for tab selection or row selection
    /// feedback in later phases. Currently unused; reserved.
    static func light(reduceMotion: Bool = false) {
        guard isEnabled, !reduceMotion else { return }
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #endif
    }

    /// Default `true` so first-launch users feel the haptic. Onboarding /
    /// Settings can flip it off.
    private static var isEnabled: Bool {
        UserDefaults.standard.object(forKey: settingsKey) as? Bool ?? true
    }
}
