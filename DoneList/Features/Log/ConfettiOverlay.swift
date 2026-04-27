// ConfettiOverlay.swift
// Full-screen, hit-test-disabled overlay that renders the active confetti variant
// via TimelineView + Canvas. Driven by DoneStore.confettiFireCount.
//
// Phase: 4
// See: decisions/0006 — Confetti via TimelineView+Canvas

import SwiftUI

struct ConfettiOverlay: View {
    let fireCount: Int

    var body: some View {
        // Phase 4 implementation — TimelineView + Canvas
        Color.clear.allowsHitTesting(false)
    }
}
