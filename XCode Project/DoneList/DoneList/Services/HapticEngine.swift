// HapticEngine.swift
// Wrapper around SensoryFeedback that honors the Settings haptic toggle
// and Reduce Motion / Reduce Animation accessibility preferences.
//
// Phase: 4
// See: decisions/0006 — Confetti (haptic always gentle)

import SwiftUI

enum HapticEngine {
    // Phase 4: SensoryFeedback.success — never .heavy/.warning/.rigid
    static func success() {
        // Phase 4 implementation
    }

    static func light() {
        // Phase 4 implementation
    }
}
