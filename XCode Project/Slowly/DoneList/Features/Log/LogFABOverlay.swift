// LogFABOverlay.swift
// iOS 26: dark FAB circle that morphs into LogFABCard via spring animation.
// Triggered by FAB tap or TodayScreen's ghost row / empty-state CTA.
// Dismiss: tap scrim · swipe-down · close button inside card.
//
// Animation: FAB and card are both in the hierarchy simultaneously, driven
// by scaleEffect + opacity so they animate in parallel (true morph feel).
// LogFABCard is only instantiated when expanded to avoid early speech init.
//
// Phase: 4.5

import SwiftUI
import DesignSystem

@available(iOS 26.0, *)
struct LogFABOverlay: View {
    @Binding var isExpanded: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var spring: Animation {
        reduceMotion ? .linear(duration: 0.15) : .spring(duration: 0.5, bounce: 0.2)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Scrim — fades in/out behind the card
            Color.black.opacity(isExpanded ? 0.25 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(isExpanded)
                .onTapGesture { isExpanded = false }

            // Card — grows from the FAB corner; only instantiated when open
            if isExpanded {
                LogFABCard(onDismiss: { isExpanded = false })
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, 90)
                    .gesture(
                        DragGesture()
                            .onEnded { if $0.translation.height > 60 { isExpanded = false } }
                    )
                    .transition(
                        reduceMotion ? .opacity :
                            .asymmetric(
                                insertion: .scale(scale: 0.3, anchor: .bottomTrailing).combined(with: .opacity),
                                removal:   .scale(scale: 0.3, anchor: .bottomTrailing).combined(with: .opacity)
                            )
                    )
            }

            // FAB — always in hierarchy so its removal animates simultaneously with card insertion
            Button { isExpanded = true } label: {
                ZStack {
                    Circle()
                        .fill(Color.textPrimary)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.surfaceApp)
                }
                .frame(width: 56, height: 56)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Log something you did")
            .padding(.trailing, Spacing.xxl)
            .padding(.bottom, 90)
            .scaleEffect(isExpanded ? 0.3 : 1, anchor: .bottomTrailing)
            .opacity(isExpanded ? 0 : 1)
            .allowsHitTesting(!isExpanded)
        }
        // Extend overlay to physical screen bottom so padding(.bottom, 90)
        // clears the tab bar (~83pt) rather than measuring from safe area edge.
        .ignoresSafeArea(.container, edges: .bottom)
        .animation(spring, value: isExpanded)
    }
}
