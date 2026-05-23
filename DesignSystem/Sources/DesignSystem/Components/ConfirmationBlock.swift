// ConfirmationBlock.swift
// Post-log confirmation / success state block.
// Centred layout: checkmark icon · headline · subtext · dismiss button.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › D0 Experience › confirmation state

import SwiftUI

/// Centred success block shown after a user logs a done item.
/// Reduce Motion: appears without scale animation.
public struct ConfirmationBlock: View {

    public let headline: String
    public let subtext: String
    public let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(headline: String, subtext: String, onDismiss: @escaping () -> Void) {
        self.headline = headline
        self.subtext = subtext
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack(spacing: Slowly.Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(Slowly.Color.accentPrimary)
                .scaleEffect(reduceMotion ? 1 : 1)  // identity — caller animates via .transition
                .accessibilityHidden(true)

            VStack(spacing: Slowly.Spacing.xs) {
                Text(headline)
                    .font(Slowly.Font.headlineRegular)
                    .foregroundStyle(Slowly.Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text(subtext)
                    .font(Slowly.Font.footnoteRegular)
                    .foregroundStyle(Slowly.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            Button("Done", action: onDismiss)
                .buttonStyle(DSButtonStyle(.secondary))
        }
        .padding(Slowly.Spacing.xxl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(headline). \(subtext)")
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Slowly.Color.surfaceApp.ignoresSafeArea()
        ConfirmationBlock(
            headline: "Logged!",
            subtext: "One more thing done. Keep going.",
            onDismiss: {}
        )
    }
}
