// FloatingLogButton.swift
// tokenInk 56pt circle FAB with plus glyph.
// Primary entry point for the Log sheet (voice-first by default — ADR-0010).
// Plus glyph keeps the affordance generic; voice surfaces inside the sheet.
//
// Phase: 9, Phase 5 (token migration to sage palette)
// See: decisions/0010 — Voice-first input + FAB navigation.md

import SwiftUI
import DesignSystem

struct FloatingLogButton: View {
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color.surfaceApp)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.textPrimary)
                        .shadow(
                            color: Color.black.opacity(0.12),
                            radius: 12,
                            x: 0,
                            y: 4
                        )
                )
        }
        .buttonStyle(FABButtonStyle(reduceMotion: reduceMotion))
        .accessibilityLabel("Log something you did")
        .accessibilityHint("Opens voice capture")
    }
}

// MARK: - Press style (scale-down on press, skipped when reduce-motion is on)

private struct FABButtonStyle: ButtonStyle {
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect((!reduceMotion && configuration.isPressed) ? 0.93 : 1.0)
            .animation(reduceMotion ? nil : .spring(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.surfaceApp.ignoresSafeArea()
        FloatingLogButton {}
    }
}
