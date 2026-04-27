// ConfettiVariants.swift
// 5-variant pool. Each variant is a pure-function particle factory.
// See: decisions/0006 — Confetti via TimelineView+Canvas
//      design-system/Components.md (Confetti variants table)
//
// Phase: 4

import Foundation
import SwiftUI

enum ConfettiVariant: CaseIterable {
    case classicPop      // 35 circles + squares · 700-1200ms · PWA parity
    case softRain        // 50 small circles · slow downward drift · pastel
    case ribbonFlutter   // 25 thin rotating rectangles · charcoal + danger
    case starBurst       // 20 SF Symbol sparkles radiating outward
    case gentleSnow      // 60 tiny dots · very slow fall · white + light gray

    static func random() -> ConfettiVariant {
        return Self.allCases.randomElement() ?? .classicPop
    }

    var maxDuration: TimeInterval {
        switch self {
        case .classicPop: return 1.4
        case .softRain: return 2.4
        case .ribbonFlutter: return 1.8
        case .starBurst: return 1.2
        case .gentleSnow: return 3.0
        }
    }

    func makeParticles(in size: CGSize) -> [ConfettiParticle] {
        // Phase 4 implementation per variant
        return []
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGVector
    var rotation: Angle
    var color: Color
    var shape: ConfettiShape
    var birth: TimeInterval
    var lifetime: TimeInterval
}

enum ConfettiShape {
    case circle, square, ribbon, sparkle, dot
}
