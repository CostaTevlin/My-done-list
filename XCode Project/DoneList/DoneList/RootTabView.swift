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

    // MARK: - iOS 26: Native TabView with charcoal tint + floating glass pill

    @ViewBuilder
    private var ios26Shell: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            ZStack(alignment: .bottomTrailing) {
                TabView {
                    TodayView(onLogTap: { showLog = true })
                        .tabItem {
                            Label("Today", systemImage: "calendar.badge.checkmark")
                        }

                    ReflectView()
                        .tabItem {
                            Label("Reflect", systemImage: "chart.bar.xaxis")
                        }
                }
                .tint(Color.tokenCharcoal)

                // Float the "+ Log" pill above the iOS 26 glass tab bar
                // instead of using `.tabViewBottomAccessory`. The accessory's
                // full-width chrome reads as an empty search slot and dilutes
                // the brand language. `brandPillStyle()` already maps to
                // `.buttonStyle(.glass)` on iOS 26, so the floating pill
                // stays native to Liquid Glass.
                LogPill { showLog = true }
                    .padding(.trailing, Spacing.lg)
                    .padding(.bottom, 110)
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

/// Brand pill that floats above the iOS 26 glass tab bar (trailing edge).
/// On iOS 18-25 the pill is the center slot of `BrandTabBar` and does not
/// use this wrapper.
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
