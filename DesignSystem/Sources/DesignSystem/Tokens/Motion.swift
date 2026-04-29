// Motion.swift
// Animation curves + durations. Mirrors design-system/Tokens.md (Motion).
//
// All motion is suppressed when @Environment(\.accessibilityReduceMotion) == true.
// The DesignSystem package does not introspect Reduce Motion itself — the call site
// must guard with the environment value or use `.transaction { ... }` overrides.
//
// Phase: 1
// See: design-system/Tokens.md (Motion)

import SwiftUI

public enum Motion {
    /// Standard ease — list item entrance, chart bar grow, fade-in.
    /// `cubicBezier(0.2, 0.9, 0.3, 1)` over 500ms.
    public static let entranceCurve = Animation.timingCurve(0.2, 0.9, 0.3, 1, duration: 0.5)

    /// Snappy — small UI flips (button press, toggle, micro-feedback).
    public static let snappy = Animation.timingCurve(0.2, 0.9, 0.3, 1, duration: 0.25)

    /// Stagger interval between rows (50ms).
    public static let entranceStagger: Double = 0.05

    /// Confetti per-particle easing — same curve as entrance, reused in Canvas math.
    /// Apply manually: `progress = cubicBezier(t, 0.2, 0.9, 0.3, 1)`.
    public enum confettiEasing {
        public static let p1: CGPoint = .init(x: 0.2, y: 0.9)
        public static let p2: CGPoint = .init(x: 0.3, y: 1.0)
    }

    /// Time after fire to remove confetti overlay = max(particle durations) + 200ms.
    public static let confettiCleanupBuffer: TimeInterval = 0.2

    /// Trailing swipe threshold for swipe-to-delete. The system handles this for
    /// `.swipeActions` so this is informational; do not re-enforce manually.
    public static let swipeThreshold: CGFloat = 80
}
