// DSButton.swift
// Slowly-branded button primitives.
//   DSButtonStyle(.primary)  — accentPrimary-fill capsule, textPrimaryWhite label
//   DSButtonStyle(.secondary) — text-only, accentPrimary tint
//   DSFABButton               — 56pt textPrimary-fill circle + SF Symbol icon
// iOS 26 glass treatment for primary deferred to R4 (needs Figma validation per screen context).
// Phase: 4.5 · D2 primitives
// Source of truth: Figma Slowly-MVP › DSButton component · primary / secondary / FAB variants

import SwiftUI

// MARK: - Primary + Secondary

public struct DSButtonStyle: ButtonStyle {
    public enum Variant { case primary, secondary }

    private let variant: Variant

    public init(_ variant: Variant) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        switch variant {
        case .primary:  primaryBody(configuration: configuration)
        case .secondary: secondaryBody(configuration: configuration)
        }
    }

    @ViewBuilder
    private func primaryBody(configuration: Configuration) -> some View {
        configuration.label
            .dsText(.bodyMedium, color: Slowly.Color.textPrimaryWhite)
            .padding(.vertical, Slowly.Spacing.sm)
            .padding(.horizontal, Slowly.Spacing.xl)
            .background(
                Capsule()
                    .fill(Slowly.Color.accentPrimary.opacity(configuration.isPressed ? 0.8 : 1))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(Motion.snappy, value: configuration.isPressed)
    }

    @ViewBuilder
    private func secondaryBody(configuration: Configuration) -> some View {
        configuration.label
            .dsText(.bodyMedium, color: Slowly.Color.accentPrimary)
            .opacity(configuration.isPressed ? 0.55 : 1)
            .animation(Motion.snappy, value: configuration.isPressed)
    }
}

// MARK: - FAB

/// Fixed-size circular FAB. Callers provide the SF Symbol name and VoiceOver label.
public struct DSFABButton: View {
    private let icon: String
    private let diameter: CGFloat
    private let accessibilityLabel: String
    private let action: () -> Void

    public init(
        icon: String,
        diameter: CGFloat = 56,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.diameter = diameter
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Circle()
                .fill(Slowly.Color.textPrimary)
                .frame(width: diameter, height: diameter)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: diameter * 0.38, weight: .medium))
                        .foregroundStyle(Slowly.Color.textPrimaryWhite)
                )
                .shadow(color: Slowly.Color.textPrimary.opacity(0.18), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Previews

#Preview("DSButton") {
    VStack(spacing: Slowly.Spacing.lg) {
        Button("Save done") {}.buttonStyle(DSButtonStyle(.primary))
        Button("Cancel") {}.buttonStyle(DSButtonStyle(.secondary))
        DSFABButton(icon: "plus", accessibilityLabel: "Add item") {}
        DSFABButton(icon: "mic.fill", accessibilityLabel: "Log with voice") {}
    }
    .padding(Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}
