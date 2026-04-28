// ConfettiVariantsTests.swift
// Phase 4 — invariants over the (random) particle factories. We don't assert
// specific particle outputs (factories use `Double.random`); we assert counts,
// duration ranges, palette membership, and easing math.
//
// See: design-system/Components.md (Confetti variants table)
//      decisions/0006 — Confetti via TimelineView+Canvas

import Testing
import Foundation
import SwiftUI
import DesignSystem
@testable import DoneList

@Suite(.serialized)
struct ConfettiVariantsTests {

    private static let canvas = CGSize(width: 393, height: 852)

    // MARK: - Counts

    @Test("each variant produces the documented particle count")
    func particleCounts() {
        #expect(ConfettiVariant.classicPop.makeParticles(in: Self.canvas).count    == 35)
        #expect(ConfettiVariant.softRain.makeParticles(in: Self.canvas).count      == 50)
        #expect(ConfettiVariant.ribbonFlutter.makeParticles(in: Self.canvas).count == 25)
        #expect(ConfettiVariant.starBurst.makeParticles(in: Self.canvas).count     == 20)
        #expect(ConfettiVariant.gentleSnow.makeParticles(in: Self.canvas).count    == 60)
    }

    // MARK: - Duration ranges (per Components.md table)

    @Test("classicPop durations fall in 0.7-1.2s")
    func classicPop_durationRange() {
        for p in ConfettiVariant.classicPop.makeParticles(in: Self.canvas) {
            #expect(p.duration >= 0.7 && p.duration <= 1.2)
            #expect(p.startDelay >= 0 && p.startDelay <= 0.20)
        }
    }

    @Test("softRain durations fall in 1.4-2.2s")
    func softRain_durationRange() {
        for p in ConfettiVariant.softRain.makeParticles(in: Self.canvas) {
            #expect(p.duration >= 1.4 && p.duration <= 2.2)
            #expect(p.startDelay >= 0 && p.startDelay <= 0.40)
        }
    }

    @Test("ribbonFlutter durations fall in 0.9-1.5s")
    func ribbonFlutter_durationRange() {
        for p in ConfettiVariant.ribbonFlutter.makeParticles(in: Self.canvas) {
            #expect(p.duration >= 0.9 && p.duration <= 1.5)
            #expect(p.startDelay >= 0 && p.startDelay <= 0.25)
        }
    }

    @Test("starBurst durations fall in 0.6-1.0s")
    func starBurst_durationRange() {
        for p in ConfettiVariant.starBurst.makeParticles(in: Self.canvas) {
            #expect(p.duration >= 0.6 && p.duration <= 1.0)
            #expect(p.startDelay >= 0 && p.startDelay <= 0.10)
        }
    }

    @Test("gentleSnow durations fall in 1.8-2.8s")
    func gentleSnow_durationRange() {
        for p in ConfettiVariant.gentleSnow.makeParticles(in: Self.canvas) {
            #expect(p.duration >= 1.8 && p.duration <= 2.8)
            #expect(p.startDelay >= 0 && p.startDelay <= 0.60)
        }
    }

    // MARK: - Shape invariants

    @Test("classicPop uses circles + squares only")
    func classicPop_shapes() {
        let particles = ConfettiVariant.classicPop.makeParticles(in: Self.canvas)
        for p in particles {
            #expect(p.shape == .circle || p.shape == .square)
        }
        // Spec calls 60% circles / 40% squares — variance is fine but we expect
        // both kinds present in 35 samples almost surely.
        let circles = particles.filter { $0.shape == .circle }.count
        let squares = particles.filter { $0.shape == .square }.count
        #expect(circles > 0 && squares > 0)
    }

    @Test("softRain particles are all circles")
    func softRain_shapes() {
        for p in ConfettiVariant.softRain.makeParticles(in: Self.canvas) {
            #expect(p.shape == .circle)
        }
    }

    @Test("ribbonFlutter particles are all ribbons")
    func ribbonFlutter_shapes() {
        for p in ConfettiVariant.ribbonFlutter.makeParticles(in: Self.canvas) {
            #expect(p.shape == .ribbon)
        }
    }

    @Test("ribbonFlutter rotates from 0 to 720°")
    func ribbonFlutter_rotation() {
        for p in ConfettiVariant.ribbonFlutter.makeParticles(in: Self.canvas) {
            #expect(p.rotationStart == .zero)
            #expect(p.rotationEnd == .degrees(720))
        }
    }

    @Test("starBurst particles are all sparkles")
    func starBurst_shapes() {
        for p in ConfettiVariant.starBurst.makeParticles(in: Self.canvas) {
            #expect(p.shape == .sparkle)
        }
    }

    @Test("gentleSnow particles are all dots")
    func gentleSnow_shapes() {
        for p in ConfettiVariant.gentleSnow.makeParticles(in: Self.canvas) {
            #expect(p.shape == .dot)
            #expect(p.size >= 1 && p.size <= 2)
        }
    }

    // MARK: - Origin geometry

    @Test("classicPop originates at bottom-center")
    func classicPop_origin() {
        let canvas = Self.canvas
        for p in ConfettiVariant.classicPop.makeParticles(in: canvas) {
            #expect(p.origin == CGPoint(x: canvas.width / 2, y: canvas.height))
        }
    }

    @Test("starBurst originates at canvas center")
    func starBurst_origin() {
        let canvas = Self.canvas
        for p in ConfettiVariant.starBurst.makeParticles(in: canvas) {
            #expect(p.origin == CGPoint(x: canvas.width / 2, y: canvas.height / 2))
        }
    }

    @Test("softRain spreads origin across the top edge")
    func softRain_origin() {
        let canvas = Self.canvas
        for p in ConfettiVariant.softRain.makeParticles(in: canvas) {
            #expect(p.origin.y == 0)
            #expect(p.origin.x >= 0 && p.origin.x <= canvas.width)
        }
    }

    // MARK: - Total lifetime / overlay timing

    @Test("totalLifetime = maxDuration + maxStagger + cleanupBuffer")
    func totalLifetime() {
        for variant in ConfettiVariant.allCases {
            let expected = variant.maxDuration + variant.maxStagger + Motion.confettiCleanupBuffer
            #expect(abs(variant.totalLifetime - expected) < 0.001)
        }
    }

    @Test("maxStagger covers every particle's startDelay")
    func maxStagger_isUpperBound() {
        for variant in ConfettiVariant.allCases {
            let particles = variant.makeParticles(in: Self.canvas)
            for p in particles {
                #expect(p.startDelay <= variant.maxStagger + 0.0001)
            }
        }
    }

    // MARK: - Easing math

    @Test("ConfettiEasing endpoints map to 0 and 1")
    func easing_endpoints() {
        for easing in [ConfettiEasing.linear, .easeOut, .cubicBezier] {
            #expect(abs(easing.apply(0)) < 0.001)
            #expect(abs(easing.apply(1) - 1) < 0.001)
        }
    }

    @Test("ConfettiEasing clamps out-of-range t to [0, 1]")
    func easing_clamps() {
        for easing in [ConfettiEasing.linear, .easeOut, .cubicBezier] {
            #expect(easing.apply(-0.5) == 0)
            #expect(abs(easing.apply(1.5) - 1) < 0.001)
        }
    }

    @Test("linear easing is identity")
    func linear_isIdentity() {
        for x in stride(from: 0.0, through: 1.0, by: 0.1) {
            #expect(abs(ConfettiEasing.linear.apply(x) - x) < 0.001)
        }
    }

    // MARK: - Random selection

    @Test("ConfettiVariant.random() returns a valid case")
    func random_returnsValidCase() {
        for _ in 0..<50 {
            let v = ConfettiVariant.random()
            #expect(ConfettiVariant.allCases.contains(v))
        }
    }
}
