// ConfettiVariants.swift
// 5-variant pool. Each variant is a pure-function particle factory.
// Numbers are direct ports of the table in design-system/Components.md.
//
// Phase: 4
// See: decisions/0006 — Confetti via TimelineView+Canvas
//      design-system/Components.md (Confetti variants table)

import Foundation
import SwiftUI
import DesignSystem

// MARK: - Variant

enum ConfettiVariant: CaseIterable {
    case classicPop      // 35 circles + squares · 700-1200ms · PWA parity
    case softRain        // 50 small circles · slow downward drift · pastel
    case ribbonFlutter   // 25 thin rotating rectangles · charcoal + danger
    case starBurst       // 20 SF Symbol sparkles radiating outward
    case gentleSnow      // 60 tiny dots · very slow fall · white + light gray

    static func random() -> ConfettiVariant {
        Self.allCases.randomElement() ?? .classicPop
    }

    /// Particles in this variant.
    var particleCount: Int {
        switch self {
        case .classicPop:    return 35
        case .softRain:      return 50
        case .ribbonFlutter: return 25
        case .starBurst:     return 20
        case .gentleSnow:    return 60
        }
    }

    /// Worst-case particle duration in seconds. Used by `ConfettiOverlay` to
    /// cleanup the layer with `max(durations) + Motion.confettiCleanupBuffer`.
    var maxDuration: TimeInterval {
        switch self {
        case .classicPop:    return 1.2
        case .softRain:      return 2.2
        case .ribbonFlutter: return 1.5
        case .starBurst:     return 1.0
        case .gentleSnow:    return 2.8
        }
    }

    /// Worst-case stagger delay; each particle's start can slip up to this.
    var maxStagger: TimeInterval {
        switch self {
        case .classicPop:    return 0.20
        case .softRain:      return 0.40
        case .ribbonFlutter: return 0.25
        case .starBurst:     return 0.10
        case .gentleSnow:    return 0.60
        }
    }

    /// Total time the overlay must stay alive after fire.
    var totalLifetime: TimeInterval {
        maxDuration + maxStagger + Motion.confettiCleanupBuffer
    }

    var easing: ConfettiEasing {
        switch self {
        case .classicPop, .ribbonFlutter: return .cubicBezier
        case .softRain, .starBurst:       return .easeOut
        case .gentleSnow:                 return .linear
        }
    }

    // MARK: - Factory

    /// Build the particle pool sized to `canvasSize`. Pure function modulo
    /// random sampling — the same call returns different particles, but
    /// invariants (count, palette membership, duration ranges) are stable.
    func makeParticles(in canvasSize: CGSize) -> [ConfettiParticle] {
        switch self {
        case .classicPop:    return makeClassicPop(in: canvasSize)
        case .softRain:      return makeSoftRain(in: canvasSize)
        case .ribbonFlutter: return makeRibbonFlutter(in: canvasSize)
        case .starBurst:     return makeStarBurst(in: canvasSize)
        case .gentleSnow:    return makeGentleSnow(in: canvasSize)
        }
    }

    // MARK: Variant 1 — Classic Pop (PWA parity)

    private func makeClassicPop(in size: CGSize) -> [ConfettiParticle] {
        let palette: [Color] = [
            .tokenCharcoal, .tokenMid, .tokenLight, .tokenBorder, .tokenBorderLight
        ]
        let origin = CGPoint(x: size.width / 2, y: size.height)
        let viewport = max(size.height, 1)

        return (0..<particleCount).map { i in
            let isCircle = Double.random(in: 0..<1) < 0.6
            let shape: ConfettiShape = isCircle ? .circle : .square
            let particleSize: CGFloat = isCircle ? .random(in: 4...7) : 2

            return ConfettiParticle(
                origin: origin,
                displacement: CGVector(
                    dx: .random(in: -60...120),
                    dy: -CGFloat.random(in: 0...(viewport * 0.85))
                ),
                color: palette[i % palette.count],
                shape: shape,
                size: particleSize,
                rotationStart: .zero,
                rotationEnd: .zero,
                startDelay: .random(in: 0...0.20),
                duration: .random(in: 0.7...1.2),
                easing: .cubicBezier
            )
        }
    }

    // MARK: Variant 2 — Soft Rain

    private func makeSoftRain(in size: CGSize) -> [ConfettiParticle] {
        let palette: [Color] = [.tokenMid, .tokenLight, .tokenBorderLight]

        return (0..<particleCount).map { i in
            ConfettiParticle(
                origin: CGPoint(x: .random(in: 0...size.width), y: 0),
                displacement: CGVector(
                    dx: .random(in: -30...30),
                    dy: .random(in: 200...600)
                ),
                color: palette[i % palette.count],
                shape: .circle,
                size: .random(in: 3...5),
                rotationStart: .zero,
                rotationEnd: .zero,
                startDelay: .random(in: 0...0.40),
                duration: .random(in: 1.4...2.2),
                easing: .easeOut
            )
        }
    }

    // MARK: Variant 3 — Ribbon Flutter

    private func makeRibbonFlutter(in size: CGSize) -> [ConfettiParticle] {
        let primary: [Color] = [.tokenCharcoal, .tokenDark]
        let origin = CGPoint(x: size.width / 2, y: size.height)
        let viewport = max(size.height, 1)
        // Spec: 3 of 25 use danger as accent.
        let dangerCount = 3
        let dangerIndices = Set((0..<particleCount).shuffled().prefix(dangerCount))

        return (0..<particleCount).map { i in
            let color: Color = dangerIndices.contains(i)
                ? .tokenDanger
                : primary[i % primary.count]
            let scale: CGFloat = .random(in: 0.8...1.2)

            return ConfettiParticle(
                origin: origin,
                displacement: CGVector(
                    dx: .random(in: -100...100),
                    dy: .random(in: -(viewport * 0.6)...20)
                ),
                color: color,
                shape: .ribbon,
                size: 2 * scale,                 // base width 2pt; height fixed 8pt in renderer
                rotationStart: .zero,
                rotationEnd: .degrees(720),
                startDelay: .random(in: 0...0.25),
                duration: .random(in: 0.9...1.5),
                easing: .cubicBezier
            )
        }
    }

    // MARK: Variant 4 — Star Burst

    private func makeStarBurst(in size: CGSize) -> [ConfettiParticle] {
        let palette: [Color] = [.tokenCharcoal, .tokenMid]
        let origin = CGPoint(x: size.width / 2, y: size.height / 2)

        return (0..<particleCount).map { i in
            let angle = Double.random(in: 0..<(2 * .pi))
            let magnitude = CGFloat.random(in: 80...200)
            return ConfettiParticle(
                origin: origin,
                displacement: CGVector(
                    dx: cos(angle) * magnitude,
                    dy: sin(angle) * magnitude
                ),
                color: palette[i % palette.count],
                shape: .sparkle,
                size: .random(in: 12...18),
                rotationStart: .degrees(.random(in: 0...360)),
                rotationEnd: .degrees(.random(in: 0...360)),
                startDelay: .random(in: 0...0.10),
                duration: .random(in: 0.6...1.0),
                easing: .easeOut
            )
        }
    }

    // MARK: Variant 5 — Gentle Snow

    private func makeGentleSnow(in size: CGSize) -> [ConfettiParticle] {
        let palette: [Color] = [.tokenWhite, .tokenBorderLight, .tokenLight]

        return (0..<particleCount).map { i in
            ConfettiParticle(
                origin: CGPoint(x: .random(in: 0...size.width), y: 0),
                displacement: CGVector(
                    dx: .random(in: -20...20),
                    dy: .random(in: 300...800)
                ),
                color: palette[i % palette.count],
                shape: .dot,
                size: .random(in: 1...2),
                rotationStart: .zero,
                rotationEnd: .zero,
                startDelay: .random(in: 0...0.60),
                duration: .random(in: 1.8...2.8),
                easing: .linear
            )
        }
    }
}

// MARK: - Particle

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var origin: CGPoint
    var displacement: CGVector
    var color: Color
    var shape: ConfettiShape
    var size: CGFloat
    var rotationStart: Angle
    var rotationEnd: Angle
    var startDelay: TimeInterval
    var duration: TimeInterval
    var easing: ConfettiEasing
}

enum ConfettiShape {
    case circle, square, ribbon, sparkle, dot
}

enum ConfettiEasing {
    case cubicBezier, easeOut, linear

    /// Apply the easing to a 0-1 progress.
    func apply(_ t: Double) -> Double {
        let clamped = max(0, min(1, t))
        switch self {
        case .linear:
            return clamped
        case .easeOut:
            // Standard ease-out: 1 - (1-t)^3
            let inv = 1 - clamped
            return 1 - inv * inv * inv
        case .cubicBezier:
            // (0.2, 0.9, 0.3, 1) — Newton-Raphson approx (≈4 iterations).
            return cubicBezier(clamped, p1x: 0.2, p1y: 0.9, p2x: 0.3, p2y: 1.0)
        }
    }

    /// Solve a 1D cubic-bezier curve for the y at parameter x.
    /// Uses `bisection` after one Newton-Raphson refinement; cheap and stable
    /// enough for visual easing (we don't need numerical perfection).
    private func cubicBezier(
        _ x: Double, p1x: Double, p1y: Double, p2x: Double, p2y: Double
    ) -> Double {
        // Bezier coefficients for x(t) = 3(1-t)²t·p1x + 3(1-t)t²·p2x + t³
        // Find t such that x(t) ≈ x by Newton-Raphson, then evaluate y(t).
        func bezier(_ t: Double, _ a: Double, _ b: Double) -> Double {
            let oneMinusT = 1 - t
            return 3 * oneMinusT * oneMinusT * t * a
                 + 3 * oneMinusT * t * t * b
                 + t * t * t
        }
        func bezierPrime(_ t: Double, _ a: Double, _ b: Double) -> Double {
            let oneMinusT = 1 - t
            return 3 * oneMinusT * oneMinusT * a
                 + 6 * oneMinusT * t * (b - a)
                 + 3 * t * t * (1 - b)
        }

        var t = x
        for _ in 0..<6 {
            let xt = bezier(t, p1x, p2x)
            let dxt = bezierPrime(t, p1x, p2x)
            guard abs(dxt) > 1e-6 else { break }
            t -= (xt - x) / dxt
            t = max(0, min(1, t))
        }
        return bezier(t, p1y, p2y)
    }
}
