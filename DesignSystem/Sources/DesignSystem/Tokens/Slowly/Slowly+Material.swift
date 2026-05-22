// Material+Tokens.swift
// Slowly Liquid Glass design-spec constants and iOS 18 material fallback.
// Param values from Figma Slowly-MVP › Liquid Glass/* variables (node 1:3932).
// iOS 26 glass params are constants documenting the Figma spec; apply via
//   .glassEffect() at the component level (not the call site) per liquid-glass.md.
// Source of truth: Figma Slowly-MVP › Liquid Glass/* variables (node 1:3932).
// Phase: 4.5 · D1 token scaffolding

import SwiftUI

public extension Slowly {

    enum Material {
        /// iOS 18–25 background material fallback.
        /// Use `.background(Slowly.Material.fallback)` in the iOS 18 branch.
        public static let fallback: SwiftUI.Material = .ultraThinMaterial
    }
}

// Liquid Glass design-spec constants — iOS 26 only.
// Reference these values when configuring GlassEffect in component code.
// Pattern:
//   if #available(iOS 26.0, *) {
//       view.glassEffect(...)  // tune with constants below
//   } else {
//       view.background(Slowly.Material.fallback)
//   }
@available(iOS 26.0, *)
public extension Slowly.Material {

    // ── Figma "Liquid Glass" variable values ─────────────────────────────────

    /// Frost - Regular · blur radius equivalent. Figma value: 7.
    static let frost: CGFloat = 7

    /// Splay - Regular · spread / diffusion. Figma value: 6.
    static let splay: CGFloat = 6

    /// Refraction · index-of-refraction scale. Figma value: 100.
    static let refraction: CGFloat = 100

    /// Dispersion · chromatic aberration. Figma value: 0 (off).
    static let dispersion: CGFloat = 0

    /// Depth - Regular · z-depth of the glass surface. Figma value: 16.
    static let depth: CGFloat = 16

    /// Light Angle · degrees clockwise from top. Figma value: -45.
    static let lightAngle: CGFloat = -45

    /// Opacity · surface opacity 0–100. Figma value: 60.
    static let opacity: CGFloat = 60
}
