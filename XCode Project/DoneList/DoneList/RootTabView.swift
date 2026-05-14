// RootTabView.swift
// Top-level navigation shell: two-branch implementation per ADR-0006.
//
// iOS 26 (if #available):
//   Native TabView (Today / Reflect / More) + FloatingLogButton overlay
//   anchored above the tab bar via Spacing.bottomSafe. Gives full control
//   over the FAB appearance vs relying on Tab(role: .search) system styling.
//
// iOS 18-25 (else):
//   Custom BrandTabBar (editorial typographic, no system chrome) with
//   inline pill + circle FAB layout. Content switches via BrandTabBar.Tab
//   selection.
//
// Both branches: LogSheet (.sheet) is identical. ConfettiOverlay on
// DoneListApp's WindowGroup.
//
// Phase: 3 (shell), 4 (Log + confetti), 5 (pill moved), 6 (two-branch),
//        7 (More tab), 4.5 (overlay FAB on iOS 26)
// See: engineering/Architecture.md  ·  design-system/Liquid Glass mapping.md
//      design-system/Components.md (BrandTabBar)  · ADR-0006

import SwiftUI
import DesignSystem

struct RootTabView: View {
    @Environment(DoneStore.self) private var store

    @State private var logMode: InputMode = .voice
    @State private var showLog: Bool = false
    @State private var editingItem: DoneItem? = nil
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
            ios18to25Shell
            #endif
        }
        .sheet(isPresented: $showLog, onDismiss: { editingItem = nil }) {
            LogSheet(initialMode: logMode, editingItem: editingItem)
                .environment(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Radius.card)
                .modifier(LiquidGlassSheetBackground())
        }
    }

    private func openLog(mode: InputMode) {
        logMode = mode
        editingItem = nil
        showLog = true
    }

    private func openEdit(item: DoneItem) {
        logMode = .text
        editingItem = item
        showLog = true
    }

    // MARK: - iOS 26: Native TabView + overlay FAB

    @ViewBuilder
    private var ios26Shell: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            IOS26ShellContent(onLog: openLog, onEdit: openEdit)
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
                    TodayView(onLog: openLog, onEditItem: openEdit)
                case .reflect:
                    ReflectView()
                case .more:
                    NavigationStack { SettingsView() }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BrandTabBar(selection: $tabSelection, onLog: { showLog = true })
        }
    }
}

// MARK: - iOS 26 shell content (extracted so Tab API is only compiled on 26+)

#if os(iOS)
@available(iOS 26.0, *)
private struct IOS26ShellContent: View {
    let onLog: (InputMode) -> Void
    let onEdit: (DoneItem) -> Void

    enum IOS26Tab: Hashable { case today, reflect, more }
    @State private var selection: IOS26Tab = .today

    var body: some View {
        TabView(selection: $selection) {
            Tab("Today", systemImage: "calendar.badge.checkmark", value: IOS26Tab.today) {
                TodayView(onLog: onLog, onEditItem: onEdit)
            }
            Tab("Reflect", systemImage: "chart.bar.xaxis", value: IOS26Tab.reflect) {
                ReflectView()
            }
            Tab("More", systemImage: "ellipsis", value: IOS26Tab.more) {
                NavigationStack { SettingsView() }
            }
        }
        .tint(Color.tokenInk)
        .overlay(alignment: .bottomTrailing) {
            FloatingLogButton { onLog(.voice) }
                .padding(.trailing, Spacing.xxl)
                .padding(.bottom, Spacing.bottomSafe)
        }
    }
}
#endif

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
