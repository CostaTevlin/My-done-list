// RootTabView.swift
// Top-level navigation shell: two-branch implementation per ADR-0006.
//
// iOS 26 (if #available):
//   Native TabView with charcoal tint — Liquid Glass chrome adapts to brand color.
//   "+ Log" pill rides in `.tabViewBottomAccessory` (trailing edge).
//
// iOS 18-25 (else):
//   Custom BrandTabBar (editorial typographic, no system chrome) with inline "+ Log" pill.
//   Content switches via BrandTabBar.Tab selection. Preserves PWA design fidelity.
//
// Both branches: LogSheet (.sheet) is identical. ConfettiOverlay on DoneListApp's WindowGroup.
//
// Phase: 3 (shell), 4 (Log + confetti), 5 (pill moved), 6 (two-branch iOS26 support)
// See: engineering/Architecture.md  · design-system/Liquid Glass mapping.md
//      design-system/Components.md (BrandTabBar, TabBarPill)  · ADR-0006

import SwiftUI
import DesignSystem

struct RootTabView: View {
    @Environment(DoneStore.self) private var store

    @State private var showLog: Bool = false
    @State private var tabSelection: BrandTabBar.Tab = .today

    var body: some View {
        Group {
            #if os(iOS)
            if #available(iOS 26.0, *) {
                ios26Shell
            } else {
                ios18to25Shell
            }
            #else
            // macOS host-build fallback (DesignSystem targets macOS for swift build)
            ios18to25Shell
            #endif
        }
        // ConfettiOverlay lives on `DoneListApp`'s WindowGroup since Phase 7
        // so onboarding's first-log step also gets the burst.
        .sheet(isPresented: $showLog) {
            LogSheet()
                .environment(store)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Radius.card)
                .modifier(LiquidGlassSheetBackground())
        }
    }

    // MARK: - iOS 26: Native TabView with charcoal tint + Liquid Glass

    @ViewBuilder
    private var ios26Shell: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            let view = TabView {
                TodayView(onLogTap: { showLog = true })
                    .tabItem { Label("Today", systemImage: "circle.fill") }

                ReflectView()
                    .tabItem { Label("Reflect", systemImage: "chart.bar.fill") }
            }
            .tint(Color.tokenCharcoal)

            view.tabViewBottomAccessory {
                // Right-align the pill inside the Liquid Glass accessory,
                // occupying the trailing edge (iOS 26's search-role tab slot).
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    LogPill { showLog = true }
                }
                .padding(.trailing, Spacing.lg)
            }
        }
        #endif
    }

    // MARK: - iOS 18-25: Editorial BrandTabBar + content switch

    @ViewBuilder
    private var ios18to25Shell: some View {
        VStack(spacing: 0) {
            Group {
                switch tabSelection {
                case .today:
                    TodayView(onLogTap: { showLog = true })
                case .reflect:
                    ReflectView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BrandTabBar(selection: $tabSelection, onLog: { showLog = true })
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

// MARK: - Liquid Glass sheet background (iOS 26 only)

/// On iOS 26, opt the LogSheet into the Liquid Glass material so the sheet
/// reads as part of the platform's design language. No-op on iOS 18-25 and
/// non-iOS host builds — the default sheet background is preserved.
private struct LiquidGlassSheetBackground: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content.presentationBackground(.thinMaterial)
        } else {
            content
        }
        #else
        content
        #endif
    }
}
