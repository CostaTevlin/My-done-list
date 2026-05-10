// ItemRow.swift
// Single row in the Today list: zero-padded rank · text · HH:mm timestamp.
// Draws its own bottom divider so the host List can hide the system separator.
//
// Phase: 3, Phase 5 (token migration to sage palette)
// See: design-system/Components.md (ItemRow)  ·  decisions/0007 — Native swipeActions

import SwiftUI
import DesignSystem

struct ItemRow: View {
    let rank: Int
    let text: String
    let time: String
    let showsDivider: Bool

    init(rank: Int, text: String, time: String, showsDivider: Bool = true) {
        self.rank = rank
        self.text = text
        self.time = time
        self.showsDivider = showsDivider
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.md) {
                Text(padded(rank))
                    .font(.num)
                    .foregroundStyle(Color.tokenInk)

                Text(text)
                    .font(.body)
                    .foregroundStyle(Color.tokenInk)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(time)
                    .font(.time)
                    .foregroundStyle(Color.tokenSlate.opacity(0.6))
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())   // full-row swipe hit-target

            if showsDivider {
                Rectangle()
                    .fill(Color.tokenMist)
                    .frame(height: 1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rank), \(text), at \(time)")
    }

    private func padded(_ n: Int) -> String {
        n < 10 ? "0\(n)" : "\(n)"
    }
}

#Preview {
    VStack(spacing: 0) {
        ItemRow(rank: 7, text: "Took a 10-min walk", time: "14:32")
        ItemRow(rank: 6, text: "Finished the budget spreadsheet that took forever", time: "13:15")
        ItemRow(rank: 5, text: "Replied to overdue emails", time: "10:02", showsDivider: false)
    }
    .padding(.horizontal, Spacing.xxl)
    .background(Color.tokenSurface)
}
