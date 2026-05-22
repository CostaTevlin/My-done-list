// DSCheckmark.swift
// Slowly-branded checkmark circle. Two states: unchecked (borderDefault stroke) and
// checked (accentPrimary fill + white checkmark). Spring-animates on state change
// unless accessibilityReduceMotion is enabled.
// Phase: 4.5 · D2 primitives
// Source of truth: Figma Slowly-MVP › "DSCheckmark" component · node TBD

import SwiftUI

public struct DSCheckmark: View {
    public let checked: Bool
    public let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(checked: Bool, size: CGFloat = 24) {
        self.checked = checked
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(checked ? Slowly.Color.accentPrimary : .clear)
                .overlay(
                    Circle().strokeBorder(
                        checked ? Slowly.Color.accentPrimary : Slowly.Color.borderDefault,
                        lineWidth: 1.5
                    )
                )

            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.45, weight: .medium))
                    .foregroundStyle(Slowly.Color.textPrimaryWhite)
            }
        }
        .frame(width: size, height: size)
        .animation(reduceMotion ? nil : .spring(duration: 0.25), value: checked)
    }
}

#Preview("DSCheckmark") {
    HStack(spacing: Slowly.Spacing.xl) {
        VStack(spacing: Slowly.Spacing.sm) {
            DSCheckmark(checked: false)
            Text("unchecked").dsText(.captionRegular, color: Slowly.Color.textSecondary)
        }
        VStack(spacing: Slowly.Spacing.sm) {
            DSCheckmark(checked: true)
            Text("checked").dsText(.captionRegular, color: Slowly.Color.textSecondary)
        }
        VStack(spacing: Slowly.Spacing.sm) {
            DSCheckmark(checked: true, size: 32)
            Text("32pt").dsText(.captionRegular, color: Slowly.Color.textSecondary)
        }
    }
    .padding(Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}
