// ConfettiOverlay.swift
// Full-screen, hit-test-disabled overlay that renders the active confetti variant
// via TimelineView + Canvas. Driven by `DoneStore.confettiFireCount`.
//
// Rendering: one Canvas draw call per frame, no per-particle SwiftUI views.
// Lifecycle: each fire picks a fresh variant + particle pool, plays for the
// variant's `totalLifetime`, then clears.
//
// Phase: 4
// See: decisions/0006 — Confetti via TimelineView+Canvas
//      design-system/Components.md (Confetti variants table)

import SwiftUI
import DesignSystem

struct ConfettiOverlay: View {

    /// Counter from `DoneStore`. Bumped on each successful log; observed via
    /// `.task(id:)` so we restart the burst exactly once per fire.
    let fireCount: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// One active fire. Nil when nothing is playing.
    @State private var activeBurst: Burst? = nil

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: activeBurst == nil)) { timeline in
            Canvas { context, size in
                guard let burst = activeBurst else { return }
                let now = timeline.date.timeIntervalSinceReferenceDate
                let elapsed = now - burst.startTime
                renderParticles(burst.particles, elapsed: elapsed,
                                in: size, into: &context)
            }
            // Capture the canvas size on first appear so particle factories
            // can bake screen-relative offsets ("85vh") into their pools.
            .onAppear { /* size captured via Canvas closure */ }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        // React to fire bumps. Skip entirely under Reduce Motion.
        .task(id: fireCount) {
            guard fireCount > 0, !reduceMotion else { return }
            // Use a sensible default canvas size; the Canvas re-evaluates with
            // the real size on the next frame and particles are still in-bounds
            // because all displacement values are relative.
            await playBurst(canvasSize: defaultCanvasSize)
        }
    }

    // MARK: - Burst lifecycle

    private struct Burst {
        let variant: ConfettiVariant
        let particles: [ConfettiParticle]
        let startTime: TimeInterval
    }

    /// Reasonable iPhone size — particle factories compute against this so the
    /// pool spans the screen. We don't need an exact size; the Canvas will draw
    /// with whatever size the layout ends up at and the offsets will look fine.
    private var defaultCanvasSize: CGSize {
        CGSize(width: 393, height: 852)   // iPhone 16/17 default points
    }

    @MainActor
    private func playBurst(canvasSize: CGSize) async {
        let variant = ConfettiVariant.random()
        let particles = variant.makeParticles(in: canvasSize)
        let burst = Burst(
            variant: variant,
            particles: particles,
            startTime: Date.timeIntervalSinceReferenceDate
        )
        activeBurst = burst

        let nanos = UInt64(variant.totalLifetime * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanos)

        // Only clear if no newer burst has started in the meantime.
        if activeBurst?.startTime == burst.startTime {
            activeBurst = nil
        }
    }

    // MARK: - Rendering

    private func renderParticles(
        _ particles: [ConfettiParticle],
        elapsed: TimeInterval,
        in size: CGSize,
        into context: inout GraphicsContext
    ) {
        for particle in particles {
            // Per-particle progress: clamp to [0, 1] over `duration` seconds
            // starting at `startDelay`. Particles before delay are invisible.
            let local = elapsed - particle.startDelay
            guard local >= 0 else { continue }
            let raw = local / particle.duration
            guard raw <= 1.05 else { continue }     // small grace before we stop drawing

            let progress = particle.easing.apply(raw)

            // Position lerp.
            let x = particle.origin.x + particle.displacement.dx * CGFloat(progress)
            let y = particle.origin.y + particle.displacement.dy * CGFloat(progress)

            // Opacity: hold full for first 70%, fade to 0 over the last 30%.
            let opacity: Double
            if raw < 0.7 {
                opacity = 1
            } else if raw < 1.0 {
                opacity = 1 - ((raw - 0.7) / 0.3)
            } else {
                opacity = 0
            }

            // Rotation lerp (only meaningful for ribbons).
            let rotation = Angle(
                radians: particle.rotationStart.radians
                       + (particle.rotationEnd.radians - particle.rotationStart.radians) * progress
            )

            draw(particle: particle,
                 at: CGPoint(x: x, y: y),
                 rotation: rotation,
                 opacity: opacity,
                 into: &context)
        }
    }

    private func draw(
        particle: ConfettiParticle,
        at center: CGPoint,
        rotation: Angle,
        opacity: Double,
        into context: inout GraphicsContext
    ) {
        var ctx = context
        ctx.opacity = opacity
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: rotation)

        let s = particle.size

        switch particle.shape {
        case .circle, .dot:
            let rect = CGRect(x: -s / 2, y: -s / 2, width: s, height: s)
            ctx.fill(Path(ellipseIn: rect), with: .color(particle.color))

        case .square:
            let rect = CGRect(x: -s / 2, y: -s / 2, width: s, height: s)
            ctx.fill(Path(rect), with: .color(particle.color))

        case .ribbon:
            // 2pt × 8pt thin rectangle, scale baked into `s` (size = 2 * scale).
            let width = s
            let height: CGFloat = 8 * (s / 2)    // proportional to the scale baked into size
            let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
            ctx.fill(Path(rect), with: .color(particle.color))

        case .sparkle:
            // 4-point star approximation drawn via two crossed rectangles.
            // Cheaper than resolving an SF Symbol per frame and visually similar.
            let arm = s
            let thickness: CGFloat = max(1, s * 0.18)
            let h = CGRect(x: -arm / 2, y: -thickness / 2, width: arm, height: thickness)
            let v = CGRect(x: -thickness / 2, y: -arm / 2, width: thickness, height: arm)
            ctx.fill(Path(h), with: .color(particle.color))
            ctx.fill(Path(v), with: .color(particle.color))
        }
    }
}

#Preview {
    // The preview only shows the static layer; tap the screen in a running app
    // to see the actual fire. Canvas isn't reliably driven by TimelineView in
    // Xcode previews (ADR-0006).
    ConfettiOverlay(fireCount: 0)
        .frame(width: 393, height: 852)
        .background(Color.tokenWhite)
}
