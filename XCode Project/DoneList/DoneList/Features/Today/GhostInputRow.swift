// GhostInputRow.swift
// Dashed-border row acting as a text-mode entry point for the Log sheet.
// Tap opens LogSheet in .text mode (ADR-0010).
//
// Phase: 9
// See: decisions/0010 — Voice-first input + FAB navigation.md

import SwiftUI
import DesignSystem

struct GhostInputRow: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.tokenLight)

                Text("Type something you did\u{2026}")
                    .font(.tokenBody)
                    .foregroundStyle(Color.tokenLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, Spacing.lg)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: Radius.card)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1, dash: [5, 4])
                    )
                    .foregroundStyle(Color.tokenBorder)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Type something you did")
        .accessibilityHint("Opens the log sheet in text mode")
    }
}

// MARK: - Preview

#Preview {
    VStack {
        GhostInputRow {}
    }
    .padding(.horizontal, Spacing.xxl)
    .background(Color.tokenWhite)
}
