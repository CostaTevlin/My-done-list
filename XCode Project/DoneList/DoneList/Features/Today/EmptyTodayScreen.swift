// EmptyTodayScreen.swift
// Empty Today state — R4 D3 rebuild per Figma 112:9873.
//
// Layout (top to bottom):
//   1. `AdaptiveHero(.empty)` masked with a concave-arc bottom — the
//      illustration's lower edge curves up ~22pt at the centre, matching
//      Figma 112:9933's Boolean-Subtract mask (Rectangle minus a wide
//      Ellipse). Mask is applied here rather than inside AdaptiveHero so
//      other AdaptiveHero consumers (populated Today, Reflect) keep their
//      straight bottom edge.
//   2. Central block — `EmptyStateSproutImage` (140×140) above a heading
//      ("No wins yet") + subtitle ("Every small step counts. You've got
//      this.").
//   3. `EmptyStateArrow` — in-flow at bottom-trailing, pointing at the FAB.
//
// Typography (per Figma 112:9884/9885):
//   - Heading:  SF Pro Light 40pt, line-height 125% (50pt)   → Slowly.Font.title1Light
//   - Subtitle: SF Pro Regular 16pt, line-height 24pt        → Slowly.Font.bodyRegular + lineSpacing(8)
//
// Copy lives in `CopyBank.emptyTodayHeadline` / `.emptyTodaySubtitle`.
//
// Phase: R4
// See: design-system/Screen specs.md (Today · empty)  ·  ADR-0010

import SwiftUI
import DesignSystem

struct EmptyTodayScreen: View {

    var onLog: (InputMode) -> Void = { _ in }

    var body: some View {
        ZStack {
            Slowly.Color.surfaceApp.ignoresSafeArea()

            // Single VStack-in-flow layout so the arrow lands below the central
            // block rather than overlapping it (the previous overlay anchored
            // the arrow to a fixed bottom inset, which collided with the new
            // sprout + heading + subtitle stack).
            VStack(spacing: 0) {
                // 1. Botanical backdrop with concave-arc bottom mask
                AdaptiveHero(state: .empty)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mask { ConcaveArcBottomShape() }

                // 2. Central sprout + headline + subtitle block
                centralBlock
                    .padding(.horizontal, Slowly.Spacing.xl)
                    .padding(.top, Slowly.Spacing.lg)
                    .frame(maxWidth: .infinity)

                // 3. Spacer pushes the arrow down toward the FAB
                Spacer(minLength: 0)

                // 4. Arrow → FAB at bottom-trailing corner (in flow, not overlay)
                HStack(spacing: 0) {
                    Spacer()
                    EmptyStateArrow()
                        // .fixedSize() locks the arrow component to its own
                        // intrinsic size so the inner Text breaks at the
                        // explicit `\n` (otherwise the HStack squeezes the
                        // text and SwiftUI truncates to one line).
                        .fixedSize()
                        .padding(.trailing, Slowly.Spacing.xxl + Slowly.Spacing.md)
                }
                .padding(.bottom, Slowly.Spacing.screenBottom + Slowly.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(CopyBank.emptyTodayHeadline). \(CopyBank.emptyTodaySubtitle.replacingOccurrences(of: "\n", with: " "))"
        )
    }

    // MARK: - Central block

    @ViewBuilder
    private var centralBlock: some View {
        VStack(spacing: Slowly.Spacing.xxl) {
            EmptyStateSproutImage()
                .frame(width: 140, height: 140)

            // .frame(maxWidth: .infinity) lets each Text take the full
            // available width so the centered multiline subtitle wraps at
            // its explicit `\n` instead of being squeezed to the heading's
            // natural width (which truncates "You've got this.").
            VStack(spacing: Slowly.Spacing.sm) {
                Text(CopyBank.emptyTodayHeadline)
                    .font(Slowly.Font.title1Light)
                    .foregroundStyle(Slowly.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(CopyBank.emptyTodaySubtitle)
                    .font(Slowly.Font.bodyRegular)               // 16pt per Figma 112:9885
                    .foregroundStyle(Slowly.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)                              // 16pt + 8 ≈ 24pt line-height
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Concave-arc bottom mask

/// Mask shape: full rect at top, with the bottom edge curving UPWARD by
/// ~22pt at the centre. Matches the Boolean-Subtract result from Figma
/// 112:9933 (Rectangle 393×278 minus an Ellipse 1078×600 centred at
/// (197, 557)). The Ellipse top-edge rises ~21pt above the Rectangle bottom
/// at the horizontal centre, then drops to meet the corners.
///
/// Tuned to feel right at the AdaptiveHero's 300pt height; if the hero is
/// resized significantly, revisit `arcDepth`.
private struct ConcaveArcBottomShape: Shape {
    var arcDepth: CGFloat = 22

    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: 0))
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        // Quadratic arc whose midpoint sits `arcDepth` above the bottom edge:
        // the control point's y is positioned so a quadratic Bézier's midpoint
        // (avg of endpoints and control × 2) lands at rect.height − arcDepth.
        p.addQuadCurve(
            to: CGPoint(x: 0, y: rect.height),
            control: CGPoint(x: rect.width / 2, y: rect.height - arcDepth * 2)
        )
        p.closeSubpath()
        return p
    }
}

// MARK: - Previews

#Preview("Empty — standalone") {
    EmptyTodayScreen()
}
