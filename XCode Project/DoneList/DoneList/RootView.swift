// RootView.swift
// Top-level shell — ADR-0010. No tab bar. Single TodayView surface with:
//   • FloatingLogButton (bottom-right via safeAreaInset)
//   • TopControls pill (top-right via overlay)
//   • Sheet routing for log / reflect / search / settings
//
// Phase: 4.5 (ADR-0010)
// See: engineering/Architecture.md · decisions/0010 · decisions/0005 (Liquid Glass)

import SwiftUI
import SwiftData
import DesignSystem

struct RootView: View {
    @Environment(DoneStore.self) private var store
    @State private var presentedSheet: SheetKind?

    var body: some View {
        TodayView(
            onLog: { mode in presentedSheet = .log(initialMode: mode) },
            onEditItem: { item in presentedSheet = .log(initialMode: .text, editingItem: item) }
        )
        // FAB — bottom-right
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 0) {
            FloatingLogButton { presentedSheet = .log(initialMode: .voice) }
                .padding(.trailing, Spacing.xxl)
                .padding(.bottom, Spacing.lg)
        }
        // TopControls pill — top-right
        .overlay(alignment: .topTrailing) {
            TopControls(
                onSearch:  { presentedSheet = .search },
                onReflect: { presentedSheet = .reflect },
                onMore:    { presentedSheet = .settings }
            )
            .padding(.trailing, Spacing.xxl)
            .padding(.top, Spacing.md)
        }
        .sheet(item: $presentedSheet) { kind in
            sheetContent(for: kind)
                .environment(store)
        }
    }

    @ViewBuilder
    private func sheetContent(for kind: SheetKind) -> some View {
        switch kind {
        case .log(let mode, let item):
            LogSheet(initialMode: mode, editingItem: item)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Radius.card)
                .modifier(LiquidGlassSheetBackground())

        case .reflect:
            ReflectView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)

        case .search:
            Text("Coming soon")
                .font(.bodyText)
                .foregroundStyle(Color.tokenSlate)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)

        case .settings:
            NavigationStack { SettingsView() }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Sheet routing enum

enum SheetKind: Identifiable {
    case log(initialMode: InputMode, editingItem: DoneItem? = nil)
    case reflect
    case search
    case settings

    var id: String {
        switch self {
        case .log(_, let item):
            if let item { return "log-edit-\(item.persistentModelID)" }
            return "log"
        case .reflect:  return "reflect"
        case .search:   return "search"
        case .settings: return "settings"
        }
    }
}

// MARK: - Liquid Glass sheet background (iOS 26 only)

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

// MARK: - Preview

#Preview {
    RootView()
        .modelContainer(for: DoneItem.self, inMemory: true)
        .environment(DoneStore())
}
