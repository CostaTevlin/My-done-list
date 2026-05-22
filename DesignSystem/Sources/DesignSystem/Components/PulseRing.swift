// PulseRing.swift
// Concentric expanding rings around a mic glyph. Used in LogSheet voice mode.
// Animation implemented with TimelineView + Canvas (per ADR-0006 — no third-party libs).
//
// States:
//   isPulsing: true,  reduceMotion: false  → animated expanding rings
//   isPulsing: false, any reduceMotion     → static double-ring (idle / waiting)
//   isPulsing: true,  reduceMotion: true   → static double-ring (RM fallback)
//
// Phase: 4.5 (ADR-0010, ADR-0006)
// See: design-system/Components.md (PulseRing)

import SwiftUI

public struct PulseRing: View {
    public let isPulsing: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(isPulsing: Bool) {
        self.isPulsing = isPulsing
    }

    public var body: some View {
        ZStack {
            if isPulsing && !reduceMotion {
                animatedRings
            } else {
                staticRings
            }
            micFill
        }
        .frame(width: 88, height: 88)
        .accessibilityLabel("Listening for your voice")
        .accessibilityAddTraits(.isImage)
    }

    // MARK: - Sub-views

    private var micFill: some View {
        ZStack {
            Circle()
                .fill(Color.textPrimary)
                .frame(width: 56, height: 56)
            Image(systemName: "mic.fill")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.surfaceApp)
        }
    }

    // Static double-ring: shown when idle or when Reduce Motion is on.
    private var staticRings: some View {
        ZStack {
            Circle()
                .stroke(Color.textPrimary.opacity(0.15), lineWidth: 1.5)
                .frame(width: 72, height: 72)
            Circle()
                .stroke(Color.textPrimary.opacity(0.08), lineWidth: 1.5)
                .frame(width: 88, height: 88)
        }
    }

    // Animated: two offset ring waves pulsing outward at ~0.8Hz via TimelineView + Canvas.
    private var animatedRings: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isPulsing)) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let innerRadius: CGFloat = 28
                let outerRadius = size.width / 2

                for offset in [0.0, 0.5] {
                    let raw = (t * 0.8 + offset).truncatingRemainder(dividingBy: 1.0)
                    let phase = CGFloat(raw < 0 ? raw + 1.0 : raw)
                    let radius = innerRadius + (outerRadius - innerRadius) * phase
                    let opacity = Double(1.0 - phase) * 0.5
                    let rect = CGRect(
                        x: center.x - radius, y: center.y - radius,
                        width: radius * 2, height: radius * 2
                    )
                    ctx.stroke(
                        Path(ellipseIn: rect),
                        with: .color(Color.textPrimary.opacity(opacity * 0.3)),
                        lineWidth: 1.5
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Pulsing (animated)") {
    ZStack {
        Color.surfaceApp.ignoresSafeArea()
        PulseRing(isPulsing: true)
    }
}

#Preview("Idle / Reduce Motion (static rings)") {
    ZStack {
        Color.surfaceApp.ignoresSafeArea()
        PulseRing(isPulsing: false)
    }
}
