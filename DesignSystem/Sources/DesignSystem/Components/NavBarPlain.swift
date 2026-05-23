// NavBarPlain.swift
// Minimal top navigation bar — title + optional trailing action.
// No hero image, no date. Used on Settings, search, and modal screens.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › nav chrome (plain bar variant)

import SwiftUI

/// Minimal navigation bar with a centred title and an optional trailing icon button.
/// Background is `surfaceApp` (opaque). For screens that need a hero behind the bar,
/// use `AdaptiveHero` directly and skip `NavBarPlain`.
public struct NavBarPlain: View {

    public let title: String
    public let trailingIcon: String?
    public let trailingAction: (() -> Void)?
    public let trailingAccessibilityLabel: String?

    public init(
        title: String,
        trailingIcon: String? = nil,
        trailingAction: (() -> Void)? = nil,
        trailingAccessibilityLabel: String? = nil
    ) {
        self.title = title
        self.trailingIcon = trailingIcon
        self.trailingAction = trailingAction
        self.trailingAccessibilityLabel = trailingAccessibilityLabel
    }

    public var body: some View {
        ZStack {
            // Title — centred regardless of trailing button presence
            Text(title)
                .font(Slowly.Font.bodyMedium)
                .foregroundStyle(Slowly.Color.textPrimary)
                .frame(maxWidth: .infinity)

            // Trailing button — absolute right
            HStack {
                Spacer()
                if let icon = trailingIcon, let action = trailingAction {
                    Button(action: action) {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(Slowly.Color.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(trailingAccessibilityLabel ?? title)
                }
            }
        }
        .padding(.horizontal, Slowly.Spacing.md)
        .frame(height: 44)
        .background(Slowly.Color.surfaceApp)
    }
}

// MARK: - Preview

#Preview("Title only") {
    NavBarPlain(title: "Settings")
        .background(Slowly.Color.surfaceApp)
}

#Preview("With trailing action") {
    NavBarPlain(
        title: "Search",
        trailingIcon: "xmark",
        trailingAction: {},
        trailingAccessibilityLabel: "Close search"
    )
    .background(Slowly.Color.surfaceApp)
}
