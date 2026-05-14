// RootTabView.swift
// Top-level navigation shell: two-branch implementation per ADR-0006.
//
// iOS 26 (if #available):
//   Native TabView with charcoal tint. Uses iOS 26's `Tab(role: .search)`
//   API to get a SECOND floating glass pill rendered as a sibling to the
//   main tab bar (same pattern Apple Music uses for its search button) —
//   we hijack it as the "Log" affordance so the system positions and styles
//   the button for us, eliminating manual alignment math.
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
//        7 (More tab), 8 (Tab(role: .search) hijack on iOS 26)
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

    // MARK: - iOS 26: Native TabView with charcoal tint + search-role Log pill

    @ViewBuilder
    private var ios26Shell: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            IOS26ShellContent(onLog: openLog, onEdit: openEdit, showLog: $showLog)
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

// MARK: - iOS 26 shell content (extracted so `Tab(role:)` is only compiled on 26+)

#if os(iOS)
@available(iOS 26.0, *)
private struct IOS26ShellContent: View {
    let onLog: (InputMode) -> Void
    let onEdit: (DoneItem) -> Void
    @Binding var showLog: Bool

    /// Selection model for the iOS 26 shell. Includes a synthetic `.log`
    /// case bound to the search-role tab. When the user taps the search
    /// pill, selection briefly flips to `.log`, we present the LogSheet,
    /// and immediately revert to whichever real tab they were on.
    enum IOS26Tab: Hashable { case today, reflect, more, log }

    @State private var selection: IOS26Tab = .today
    @State private var lastRealTab: IOS26Tab = .today

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

            // Search-role hijack: renders as a separate floating glass
            // pill (Apple Music pattern), perfectly inline with the main
            // tab bar. We never actually navigate to it — the .onChange
            // handler intercepts, fires the LogSheet, and snaps selection
            // back to the previous real tab.
            Tab("Log", systemImage: "mic.fill", value: IOS26Tab.log, role: .search) {
                Color.clear // unused; we revert before this could appear
            }
        }
        .tint(Color.tokenInk)
        .onChange(of: selection) { oldValue, newValue in
            guard newValue == .log else {
                lastRealTab = newValue
                return
            }
            showLog = true
            // Revert immediately so the empty `.log` content never shows.
            // Use the last known real tab; if there isn't one, default to .today.
            selection = (oldValue == .log) ? lastRealTab : oldValue
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
