// AdaptiveHero.swift
// Multi-state hero backdrop shared across Today (populated + empty) and Reflect.
// Composition is identical across states — watercolour photo + dark glow + concave-arc
// mask + inner shadow. Only the height and the inline content overlay change:
//
//   • .today    → Compact (95pt). No content overlay. Per Figma 112:9511, the
//                 watercolour band sits behind the navbar / status bar; date,
//                 BigNumeral, headline, and subtitle are composed by the screen
//                 below the band (Figma 112:9687).
//   • .empty    → Expanded (300pt). No content overlay. Empty-state sprout +
//                 heading + subtitle live below the hero (Figma 112:9881).
//   • .reflect  → Expanded (300pt) with "Reflect" label + headline + subtitle
//                 overlaid on the watercolour.
//
// State changes animate height + content swap together (.animation on `state`).
//
// Phase: R5 · navbar-hero parity
// See: Figma Slowly-MVP › 111:8965 (hero component set) ·
//      112:9511 / 112:9520 (Compact / Expanded variants) ·
//      112:9678 / 112:9873 / 112:9060 (Today / Empty / Reflect screens) ·
//      ADR redesign-techdebt-001 (hybrid raster + native composition).

import SwiftUI

// MARK: - State

/// The three display states of the adaptive hero.
public enum HeroState: Equatable {
    /// Today populated. Compact backdrop only — the screen composes date,
    /// BigNumeral, headline, and subtitle below the hero band.
    /// `date`, `headline`, `subtitle` are kept on the case for accessibility
    /// summarisation only; they are not rendered inside the hero.
    case today(date: String, headline: String, subtitle: String)
    /// Reflect screen. Expanded backdrop with "Reflect" label + headline + subtitle overlay.
    case reflect(headline: String, subtitle: String)
    /// Today empty. Expanded backdrop only — sprout + heading + subtitle live below the hero.
    case empty
}

// MARK: - Component

/// Adaptive hero backdrop shared across Today and Reflect. Height adapts
/// (95pt Compact / 300pt Expanded) and the optional text overlay fades in/out
/// as `state` changes.
public struct AdaptiveHero: View {

    public let state: HeroState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(state: HeroState) {
        self.state = state
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Backdrop bleeds behind the status bar / Dynamic Island / transparent
            // navbar — only the watercolour, glow, and arc extend into the safe area.
            backdrop
                .frame(height: backdropHeight)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            // Text overlay (Reflect state only) respects the safe area so the
            // label and headline don't collide with the status bar / Dynamic Island.
            // The overlay's own .padding(.top, screenTop) then offsets it below
            // the safe area inset.
            reflectOverlay
        }
        .frame(height: backdropHeight)
        .frame(maxWidth: .infinity)
        .modifier(HeroAccessibility(state: state))
        .animation(reduceMotion ? nil : .spring(duration: 0.4, bounce: 0.1), value: state)
    }

    // MARK: - Geometry

    // Compact = 95.13pt (Figma 112:9511) · Expanded = 300pt (Figma 112:9520).
    private var backdropHeight: CGFloat {
        switch state {
        case .today:           return 95
        case .reflect, .empty: return 300
        }
    }

    // MARK: - Backdrop

    // Hybrid composition per ADR redesign-techdebt-001, matched to Figma
    // 112:9023 (Compact mask group) and 112:9521 (Expanded mask group):
    //   1. Dark glow ellipse — #1C1C1E (textPrimary) at 0.10 opacity, Gaussian
    //      blur stdDev 27 (≈54pt in SwiftUI). Provides the soft depth halo
    //      behind the watercolour.
    //   2. Watercolour photo, anchored at the TOP and sized to the larger of
    //      (frame height, intrinsic 393×278 aspect) so the leafy top corners
    //      stay visible at any height. Rendered with `.blendMode(.darken)` so
    //      only the darker watercolour pigments survive the white surface —
    //      matches the Figma `mix-blend-mode: darken` on this layer.
    //   3. State-specific opacity per Figma:
    //        • Compact  → 1.0 (Figma 112:9028, no opacity class)
    //        • Expanded → 0.3 (Figma 112:9526, `opacity-30`)
    //   4. Inner shadow along the arc edge — strokeBorder + downward offset +
    //      blur, masked back to the shape so the dark band only renders along
    //      the top inside boundary. Softened on Compact to match the gentler
    //      arc edge in Figma 112:9511.
    private var backdrop: some View {
        GeometryReader { geo in
            let intrinsicAspect: CGFloat = 393.0 / 278.0
            let imageHeight = max(geo.size.height, geo.size.width / intrinsicAspect)

            ZStack(alignment: .top) {
                Ellipse()
                    .fill(Slowly.Color.textPrimary)
                    .frame(width: geo.size.width * 2.74, height: geo.size.width * 1.527)
                    .position(x: geo.size.width / 2, y: geo.size.height * 0.7)
                    .blur(radius: 54)
                    .opacity(0.10)

                Image("navBarHero", bundle: .module)
                    .resizable()
                    .frame(width: geo.size.width, height: imageHeight)
                    .opacity(imageOpacity)
                    .blendMode(.darken)
            }
        }
        .clipShape(ConcaveArc(dip: arcDip))
        .overlay {
            ConcaveArc(dip: arcDip)
                .stroke(Color.black.opacity(arcShadowOpacity), lineWidth: 8)
                .offset(y: 5)
                .blur(radius: 4)
                .mask(ConcaveArc(dip: arcDip))
        }
        .allowsHitTesting(false)
    }

    // Arc dip in absolute points — Figma compact mask SVG: corners at ~95pt,
    // centre at 58pt → 37pt dip. Expanded: 22pt dip (Figma 112:9933).
    // Because ConcaveArc.dip is Animatable, the arc shape morphs during
    // the empty↔populated height transition.
    private var arcDip: CGFloat {
        switch state {
        case .today:           return 37
        case .reflect, .empty: return 22
        }
    }

    // Per Figma 112:9028 (Compact image) vs 112:9526 (Expanded image, opacity-30).
    // Compact uses full opacity to keep the leafy corners present even at 95pt.
    // Expanded is dialled down so the watercolour reads as a soft botanical
    // backdrop — Figma spec is 0.3 but SwiftUI's darken composite differs from
    // CSS mix-blend-mode; 0.7 matches the rendered Figma frame more closely.
    private var imageOpacity: Double {
        switch state {
        case .today:           return 1.0
        case .reflect, .empty: return 0.7
        }
    }

    // Softer arc edge on Compact so the 95pt band reads as a navbar wash
    // rather than a hard divider; Expanded keeps the stronger edge to anchor
    // the 300pt hero.
    private var arcShadowOpacity: Double {
        switch state {
        case .today:           return 0.12
        case .reflect, .empty: return 0.25
        }
    }

    // MARK: - Reflect overlay

    // Only state with text inside the hero. Empty / Today render their content
    // outside the component, so the hero stays a pure backdrop there.
    @ViewBuilder
    private var reflectOverlay: some View {
        if case let .reflect(headline, subtitle) = state {
            VStack(alignment: .leading, spacing: Slowly.Spacing.sm) {
                Text("Reflect")
                    .font(Slowly.Font.bodyMedium)
                    .foregroundStyle(Slowly.Color.textSecondary)
                Text(headline)
                    .font(Slowly.Font.title1Light)
                    .foregroundStyle(Slowly.Color.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                Text(subtitle)
                    .font(Slowly.Font.headlineRegular)
                    .foregroundStyle(Slowly.Color.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(6)
                    .lineLimit(2)
            }
            .padding(.horizontal, Slowly.Spacing.xl)
            .padding(.top, Slowly.Spacing.screenTop)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity)
        }
    }
}

// MARK: - Accessibility

// Today + Empty backdrops are purely decorative; the screen composes the real
// text below the hero and that copy carries its own VoiceOver labels.
// Reflect carries its overlay text, so we surface it as a single element.
private struct HeroAccessibility: ViewModifier {
    let state: HeroState

    func body(content: Content) -> some View {
        switch state {
        case let .reflect(headline, subtitle):
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Reflect. \(headline). \(subtitle)")
        case .today, .empty:
            content.accessibilityHidden(true)
        }
    }
}

// MARK: - Concave-arc mask

// Bottom edge curves UP at the centre by `dip` absolute points.
//
// Values per Figma:
//   Compact (95pt): mask SVG path "M393 94.75 C…197 58…0 95.14" — corners at
//     ~95pt, centre at 58pt → dip = 37pt.  Gives the deep pronounced arc
//     visible in Figma 112:9511.
//   Expanded (300pt): Rectangle 393×278 + Ellipse boolean-subtract (Figma
//     112:9933) → 22pt dip at 300pt height.
//
// `dip` is `Animatable` so the arc shape morphs smoothly during the
// empty (22pt) ↔ populated (37pt) spring transition in AdaptiveHero.
private struct ConcaveArc: Shape {
    // Absolute dip in points — how far the arc centre rises above the corners.
    var dip: CGFloat

    var animatableData: CGFloat {
        get { dip }
        set { dip = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        // For a quadratic bezier from (w, h) to (0, h) with control point at
        // (w/2, controlY), the midpoint sits at y = (h + controlY) / 2.
        // Setting midpoint = h − dip  →  controlY = h − 2*dip.
        let safeDip  = min(dip, rect.height * 0.85)
        let controlY = rect.height - safeDip * 2
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height),
            control: CGPoint(x: rect.width / 2, y: controlY)
        )
        p.closeSubpath()
        return p
    }
}

// MARK: - Preview

#Preview("Today — compact backdrop") {
    VStack(alignment: .leading, spacing: 0) {
        AdaptiveHero(state: .today(
            date: "Monday, 18 May",
            headline: "You're on a roll now",
            subtitle: "Some motivational subtitle goes here maybe in two lines"
        ))

        VStack(alignment: .leading, spacing: Slowly.Spacing.sm) {
            Text("Monday, 18 May")
                .font(Slowly.Font.bodyMedium)
                .foregroundStyle(Slowly.Color.textSecondary)
            BigNumeral(value: 7)
            Text("You're on a roll now")
                .font(Slowly.Font.title1Light)
                .foregroundStyle(Slowly.Color.textPrimary)
            Text("Some motivational subtitle goes here maybe in two lines")
                .font(Slowly.Font.headlineRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
        }
        .padding(.horizontal, Slowly.Spacing.xl)
        .padding(.top, Slowly.Spacing.md)

        Spacer()
    }
    .background(Slowly.Color.surfaceApp)
    .ignoresSafeArea(edges: .top)
}

#Preview("Reflect — expanded with overlay") {
    AdaptiveHero(state: .reflect(
        headline: "What a great week",
        subtitle: "Some motivational subtitle."
    ))
    .background(Slowly.Color.surfaceApp)
    .ignoresSafeArea(edges: .top)
}

#Preview("Empty — expanded backdrop only") {
    AdaptiveHero(state: .empty)
        .background(Slowly.Color.surfaceApp)
        .ignoresSafeArea(edges: .top)
}

#Preview("State swap (tap to cycle)") {
    StatefulPreviewWrapper()
}

private struct StatefulPreviewWrapper: View {
    @State private var index = 0
    private var states: [HeroState] {
        [
            .today(date: "Monday, 18 May", headline: "You're on a roll now", subtitle: "Some motivational subtitle"),
            .reflect(headline: "What a great week", subtitle: "Keep it going."),
            .empty
        ]
    }
    var body: some View {
        VStack(spacing: 0) {
            AdaptiveHero(state: states[index])
            Spacer()
            Button("Cycle state") { index = (index + 1) % states.count }
                .padding()
        }
        .background(Slowly.Color.surfaceApp)
        .ignoresSafeArea(edges: .top)
    }
}
