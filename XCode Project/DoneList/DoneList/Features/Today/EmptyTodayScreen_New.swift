// EmptyTodayScreen_New.swift
// Empty Today state — R4 rebuild on D3 composites.
// AdaptiveHero(.empty) fills the top; EmptyStateArrow floats toward the FAB corner.
//
// Phase: R4
// See: design-system/Screen specs.md (Today · empty)  ·  ADR-0010

import SwiftUI
import DesignSystem

struct EmptyTodayScreen_New: View {

    var onLog: (InputMode) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Slowly.Color.surfaceApp.ignoresSafeArea()

            // Hero — botanical backdrop only (no text per Figma 111:8965)
            AdaptiveHero(state: .empty)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Arrow nudges toward the FAB (bottom-trailing corner)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    EmptyStateArrow()
                        .padding(.trailing, Slowly.Spacing.xxl + Slowly.Spacing.md)
                        .padding(.bottom, Slowly.Spacing.screenBottom + Slowly.Spacing.xl)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("Empty — standalone") {
    EmptyTodayScreen_New()
}
