// EmptyTodayScreen.swift
// Empty Today state — R4 D3 rebuild per Figma 112:9873.
//
// Layout (top to bottom):
//   1. `AdaptiveHero(.empty)` — botanical backdrop, 300pt.
//      (Note: Figma 112:9873 renders the hero with a concave-arc bottom
//      mask. The current AdaptiveHero `.empty` variant has a flat bottom;
//      the concave variant is a polish follow-up and does not block this
//      task.)
//   2. Central block — `EmptyStateSproutImage` (140×140) above a heading
//      ("No wins yet") + subtitle ("Every small step counts. You've got
//      this.").
//   3. `EmptyStateArrow` — anchored bottom-trailing as an overlay,
//      pointing at the FAB.
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
                // 1. Botanical backdrop (matches the populated-state hero in height)
                AdaptiveHero(state: .empty)
                    .frame(maxWidth: .infinity, alignment: .leading)

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
                    .font(Slowly.Font.headlineRegular)
                    .foregroundStyle(Slowly.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Previews

#Preview("Empty — standalone") {
    EmptyTodayScreen()
}
