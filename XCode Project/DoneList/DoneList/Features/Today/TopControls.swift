// TopControls.swift
// Horizontal pill with Search · Reflect · More glyphs. Top-right of the screen.
// iOS 26: glassEffect(.regular). iOS 18: thinMaterial + charcoal-tinted shadow.
// Each glyph has a 44pt minimum hit-target (VoiceOver / Switch Control).
//
// Phase: 4.5 (ADR-0010, ADR-0005)
// See: decisions/0010 — Voice-first input + FAB navigation
//      decisions/0005 — Liquid Glass with #available fallback

import SwiftUI
import DesignSystem

struct TopControls: View {
    let onSearch:  () -> Void
    let onReflect: () -> Void
    let onMore:    () -> Void

    var body: some View {
        HStack(spacing: 0) {
            controlButton(icon: "magnifyingglass", label: "Search",  action: onSearch)
            controlButton(icon: "chart.bar",       label: "Reflect", action: onReflect)
            controlButton(icon: "ellipsis",        label: "More",    action: onMore)
        }
        .padding(.horizontal, Spacing.sm)
        .background { pillBackground }
        .clipShape(Capsule())
    }

    private func controlButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.tokenInk)
                // 44pt minimum hit-target
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    @ViewBuilder
    private var pillBackground: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            Color.clear.glassEffect(.regular)
        } else {
            Capsule()
                .fill(.thinMaterial)
                .overlay(
                    Capsule()
                        .fill(Color.tokenInk.opacity(0.06))
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        #else
        Capsule().fill(.thinMaterial)
        #endif
    }
}

// MARK: - Preview

#Preview {
    ZStack(alignment: .topTrailing) {
        Color.tokenSurface.ignoresSafeArea()
        TopControls(onSearch: {}, onReflect: {}, onMore: {})
            .padding()
    }
}
