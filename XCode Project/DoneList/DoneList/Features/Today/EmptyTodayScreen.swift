// EmptyTodayScreen.swift
// Empty Today state — content portion (everything below the shared AdaptiveHero).
//
// Hero, surface background, and the ZStack containing both live in
// `TodayScreen` so the hero is a SINGLE instance that animates smoothly when
// `todayItems` flips between empty and populated. This file owns just the
// in-flow body (sprout + heading + subtitle + arrow → FAB).
//
// Layout (top to bottom, below the 300pt Expanded hero):
//   1. Central block — `EmptyStateSproutImage` (140×140) above a heading
//      ("No wins yet") + subtitle ("Every small step counts. You've got
//      this.").
//   2. `EmptyStateArrow` — in-flow at bottom-trailing, pointing at the FAB.
//
// Typography (per Figma 112:9884/9885):
//   - Heading:  SF Pro Light 40pt, line-height 125% (50pt)   → Slowly.Font.title1Light
//   - Subtitle: SF Pro Regular 16pt, line-height 24pt        → Slowly.Font.bodyRegular + lineSpacing(8)
//
// Copy lives in `CopyBank.emptyTodayHeadline` / `.emptyTodaySubtitle`.
//
// Phase: R4 (R5 hero-animation refactor — hero hoisted to TodayScreen)
// See: design-system/Screen specs.md (Today · empty)  ·  ADR-0010

import SwiftUI
import DesignSystem

struct EmptyTodayScreen: View {

    var onLog: (InputMode) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            // 1. Central sprout + headline + subtitle block
            centralBlock
                .padding(.horizontal, Slowly.Spacing.xl)
                .padding(.top, Slowly.Spacing.lg)
                .frame(maxWidth: .infinity)

            // 2. Spacer pushes the arrow down toward the FAB
            Spacer(minLength: 0)

            // 3. Arrow → FAB at bottom-trailing corner (in flow, not overlay)
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

// MARK: - Previews

#Preview("Empty — content only (no hero)") {
    EmptyTodayScreen()
        .background(Slowly.Color.surfaceApp)
}
