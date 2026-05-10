// UndoToast.swift
// 4-second bottom toast shown after swipe-to-delete.
// Tap "Undo" to re-insert the deleted item.
//
// Phase: 9, Phase 5 (token migration to sage palette)
// See: decisions/0010 — Voice-first input + FAB navigation.md

import SwiftUI
import DesignSystem

struct UndoToast: View {
    let onUndo: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: Spacing.lg) {
            Text("Deleted")
                .font(.bodySub)
                .foregroundStyle(Color.tokenSurface)

            Spacer()

            Button("Undo") {
                onUndo()
            }
            .font(.bodySub)
            .fontWeight(.semibold)
            .foregroundStyle(Color.tokenSurface)
            .accessibilityLabel("Undo delete")
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.md)
        .background(
            Capsule()
                .fill(Color.tokenInk)
                .shadow(color: Color.black.opacity(0.15), radius: 8, y: 3)
        )
        .padding(.horizontal, Spacing.xxl)
        .transition(
            reduceMotion
                ? .opacity
                : .move(edge: .bottom).combined(with: .opacity)
        )
        .task {
            // Auto-dismiss after 4 seconds.
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            withAnimation(reduceMotion ? nil : .spring(duration: 0.3)) {
                onDismiss()
            }
        }
        .onTapGesture {
            // Dismiss without undo when tapping the background of the toast.
            // Undo is handled by the button above.
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack(alignment: .bottom) {
        Color.tokenSurface.ignoresSafeArea()
        UndoToast(onUndo: {}, onDismiss: {})
            .padding(.bottom, Spacing.lg)
    }
}
