// RootTabView.swift
// Top-level navigation shell: native `TabView` (Today + Reflect tabs) with
// the "+ Log" pill attached as a right-aligned accessory — placed where
// iOS 26's search-role tab would normally live.
//
// On iOS 26 the pill rides inside `.tabViewBottomAccessory` (Liquid Glass).
// On iOS 18-25 it floats trailing-aligned above the tab bar via a ZStack.
//
// Phase: 3 (shell), 4 (Log + confetti wired here), 5 (Log moved to trailing edge)
// See: engineering/Architecture.md  · design-system/Liquid Glass mapping.md
//      design-system/Components.md (TabBarPill)  · ADR-0005, ADR-0006

import SwiftUI
import DesignSystem

struct RootTabView: View {
    @Environment(DoneStore.self) private var store

    @State private var showLog: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            tabs
            // Fallback log pill — iOS 18-25 only. iOS 26 attaches the pill via
            // `.tabViewBottomAccessory` (see `tabs` below).
            if #unavailable(iOS 26.0) {
                LogPill { showLog = true }
                    .padding(.trailing, Spacing.lg)
                    .padding(.bottom, 60)
            }
        }
        // ConfettiOverlay lives on `DoneListApp`'s WindowGroup since Phase 7
        // so onboarding's first-log step also gets the burst.
        .sheet(isPresented: $showLog) {
            LogSheet()
                .environment(store)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Radius.card)
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
                // Right-align the pill inside the accessory so it occupies
                // the trailing edge of the tab bar — the slot where iOS 26's
                // search-role tab usually sits.
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    LogPill { showLog = true }
                }
                .padding(.trailing, Spacing.lg)
            }
        } else {
            view
        }
    }
}

// MARK: - Floating "+ Log" pill

/// Brand pill anchored to the trailing edge of the tab bar. On iOS 26 it
/// lives inside `.tabViewBottomAccessory`; on iOS 18-25 it floats via the
/// ZStack above.
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
