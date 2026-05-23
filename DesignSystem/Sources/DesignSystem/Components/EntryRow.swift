// EntryRow.swift
// Single done-item row: checkmark · title + timestamp · actions menu.
// Swipe-to-delete and tap-to-edit are wired at the app feature layer (R4), not here.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › D0 Experience › Today screen rows

import SwiftUI

/// A single logged done-item row.
/// Place inside a `LazyVStack` or `List`. Use `isLast: true` on the final
/// item in a section to suppress the trailing divider.
public struct EntryRow: View {

    public let text: String
    public let timestamp: String
    /// When true the bottom `DSDivider` is hidden — use for the last row in a group.
    public let isLast: Bool
    /// Optional mic icon shown below the title to indicate a voice-captured entry.
    public let isVoiceCaptured: Bool
    /// Triggered when the ellipsis button is tapped. Supply `nil` to hide the button.
    public let onMenu: (() -> Void)?

    public init(
        text: String,
        timestamp: String,
        isLast: Bool = false,
        isVoiceCaptured: Bool = false,
        onMenu: (() -> Void)? = nil
    ) {
        self.text = text
        self.timestamp = timestamp
        self.isLast = isLast
        self.isVoiceCaptured = isVoiceCaptured
        self.onMenu = onMenu
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: Slowly.Spacing.sm) {
                checkmark
                titleStack
                Spacer(minLength: Slowly.Spacing.xs)
                menuButton
            }
            .padding(.vertical, Slowly.Spacing.sm)
            .contentShape(Rectangle())

            if !isLast {
                DSDivider()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
    }

    // MARK: - Subviews

    private var checkmark: some View {
        DSCheckmark(checked: true, size: 20)
            .accessibilityHidden(true)
    }

    private var titleStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(text)
                .font(Slowly.Font.bodyRegular)
                .foregroundStyle(Slowly.Color.textPrimary)
                .multilineTextAlignment(.leading)

            HStack(spacing: 4) {
                if isVoiceCaptured {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Slowly.Color.textSecondary)
                        .accessibilityHidden(true)
                }
                Text(timestamp)
                    .font(Slowly.Font.captionRegular)
                    .foregroundStyle(Slowly.Color.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var menuButton: some View {
        if let onMenu {
            Button(action: onMenu) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Slowly.Color.textSecondary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("More options for \(text)")
        }
    }

    // MARK: - Accessibility

    private var a11yLabel: String {
        var label = "\(text), \(timestamp)"
        if isVoiceCaptured { label += ", voice captured" }
        return label
    }
}

// MARK: - Preview

#Preview("Standard rows") {
    VStack(spacing: 0) {
        EntryRow(text: "Took a 10-min walk", timestamp: "00:33", onMenu: {})
        EntryRow(text: "Paid rent", timestamp: "00:33", onMenu: {})
        EntryRow(
            text: "Did my laundry",
            timestamp: "00:33",
            isLast: true,
            isVoiceCaptured: true,
            onMenu: {}
        )
    }
    .padding(.horizontal, Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}

#Preview("No menu") {
    VStack(spacing: 0) {
        EntryRow(text: "Finished the deck for tomorrow's review", timestamp: "14:05")
        EntryRow(text: "Reviewed the quarterly report", timestamp: "09:20", isLast: true)
    }
    .padding(.horizontal, Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}
