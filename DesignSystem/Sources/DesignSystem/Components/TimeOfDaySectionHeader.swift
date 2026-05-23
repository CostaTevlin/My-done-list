// TimeOfDaySectionHeader.swift
// Morning / Afternoon / Evening section label with item count badge.
// Sits above a group of EntryRow items with no background of its own.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › D0 Experience › Today screen section headers

import SwiftUI

/// Section header for time-of-day groups in the Today list.
/// Example: "Afternoon (6)" or "Morning (1)".
public struct TimeOfDaySectionHeader: View {

    public let label: String
    public let count: Int

    public init(label: String, count: Int) {
        self.label = label
        self.count = count
    }

    public var body: some View {
        HStack(spacing: Slowly.Spacing.xs) {
            Text(label)
                .font(Slowly.Font.footnoteMedium)
                .foregroundStyle(Slowly.Color.textSecondary)

            Text("(\(count))")
                .font(Slowly.Font.footnoteRegular)
                .foregroundStyle(Slowly.Color.textSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(count) \(count == 1 ? "item" : "items")")
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: Slowly.Spacing.md) {
        TimeOfDaySectionHeader(label: "Morning", count: 1)
        TimeOfDaySectionHeader(label: "Afternoon", count: 6)
        TimeOfDaySectionHeader(label: "Evening", count: 0)
    }
    .padding(.horizontal, Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}
