// RootTabView.swift
// Top-level navigation shell: TabView with Today + Reflect tabs, the floating
// "+ Log" pill (Liquid Glass on iOS 26 / overlay fallback on iOS 18-25), the
// LogSheet bottom sheet, and the full-screen ConfettiOverlay.
//
// Phase: 3 (shell), Phase 4 (Log + confetti wired here)
// See: engineering/Architecture.md  ·  design-system/Liquid Glass mapping.md
//      design-system/Components.md (TabBarPill)  ·  ADR-0005, ADR-0006

import SwiftUI
import DesignSystem

struct RootTabView: View {
    @Environment(DoneStore.self) private var store

    @State private var showLog: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            tabs
            // Fallback log pill — iOS 18-25 only. iOS 26 attaches the pill via
            // `.tabViewBottomAccessory` (see `tabs` below).
            if #unavailable(iOS 26.0) {
                LogPill { showLog = true }
                    .padding(.bottom, 60)
            }
        }
        .overlay {
            ConfettiOverlay(fireCount: store.confettiFireCount)
        }
        .sheet(isPresented: $showLog) {
            LogSheet()
                .environment(store)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(14)
        }
    }

    @ViewBuilder
    private var tabs: some View {
        let view = TabView {
            TodayView(onLogTap: { showLog = true })
                .tabItem { Label("Today", systemImage: "circle.fill") }

            ReflectView()
                .tabItem { Label("Reflect", systemImage: "chart.bar.fill") }
        }

        if #available(iOS 26.0, *) {
            view.tabViewBottomAccessory {
                LogPill { showLog = true }
            }
        } else {
            view
        }
    }
}

// MARK: - Floating "+ Log" pill

/// Brand pill above the tab bar. On iOS 26 it lives inside
/// `.tabViewBottomAccessory`; on iOS 18-25 it floats via the ZStack above.
private struct LogPill: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("+ Log")
                .font(.tokenBody.weight(.medium))
        }
        .brandPillStyle()
        .accessibilityLabel("Log something you did")
    }
}
