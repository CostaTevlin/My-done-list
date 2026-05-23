// TabBarMain.swift
// Floating tab bar with Today · Reflect · More tabs + circular log FAB.
// Slowly-token clean build. BrandTabBar.swift stays as the app target's current
// implementation; this component is wired to screens in R4.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › D0 Experience › bottom nav bar

import SwiftUI

// MARK: - Tab enum

public extension TabBarMain {
    enum Tab: Hashable, CaseIterable {
        case today, reflect, more

        var label: String {
            switch self {
            case .today:   return "Today"
            case .reflect: return "Reflect"
            case .more:    return "More"
            }
        }

        var icon: String {
            switch self {
            case .today:   return "calendar.badge.checkmark"
            case .reflect: return "chart.bar"
            case .more:    return "ellipsis"
            }
        }
    }
}

// MARK: - Component

/// Floating bottom tab bar matching the Slowly Figma design.
/// Active tab: `textPrimary`-fill capsule pill, icon + label in `textPrimaryWhite`.
/// Inactive: icon + label in `textSecondary`. FAB: 60pt `textPrimary`-fill circle.
public struct TabBarMain: View {

    @Binding public var selection: Tab
    public let onLog: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(selection: Binding<Tab>, onLog: @escaping () -> Void) {
        self._selection = selection
        self.onLog = onLog
    }

    public var body: some View {
        HStack(alignment: .center, spacing: Slowly.Spacing.sm) {
            tabPill
            logFAB
        }
        .padding(.horizontal, Slowly.Spacing.lg)
        .padding(.vertical, Slowly.Spacing.xs)
        .background(
            Capsule(style: .continuous)
                .fill(Slowly.Color.surfaceApp)
                .shadow(color: Slowly.Color.textPrimary.opacity(0.08), radius: 16, y: 4)
        )
    }

    // MARK: - Tab pill

    private var tabPill: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabItem(tab)
            }
        }
        .padding(Slowly.Spacing.xs)
        .background(
            Capsule(style: .continuous)
                .fill(Slowly.Color.borderDefault)
        )
    }

    private func tabItem(_ tab: Tab) -> some View {
        Button {
            selection = tab
        } label: {
            VStack(spacing: 3) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        selection == tab ? Slowly.Color.textPrimaryWhite : Slowly.Color.textSecondary
                    )
                Text(tab.label)
                    .font(Slowly.Font.captionBold)
                    .foregroundStyle(
                        selection == tab ? Slowly.Color.textPrimaryWhite : Slowly.Color.textSecondary
                    )
            }
            .padding(.horizontal, Slowly.Spacing.md)
            .padding(.vertical, Slowly.Spacing.xs)
            .frame(minHeight: 52)
            .background {
                if selection == tab {
                    Capsule(style: .continuous)
                        .fill(Slowly.Color.textPrimary)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tab.label) tab")
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
        .animation(reduceMotion ? .none : .spring(duration: 0.25, bounce: 0.15), value: selection)
    }

    // MARK: - Log FAB

    private var logFAB: some View {
        Button(action: onLog) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Slowly.Color.textPrimaryWhite)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Slowly.Color.textPrimary)
                        .shadow(color: Slowly.Color.textPrimary.opacity(0.2), radius: 8, y: 4)
                )
        }
        .accessibilityLabel("Log something you did")
        .accessibilityHint("Opens voice capture")
    }
}

// MARK: - Preview

#Preview("Today selected") {
    VStack {
        Spacer()
        StatefulPreviewWrapper(TabBarMain.Tab.today) { selection in
            TabBarMain(selection: selection, onLog: {})
                .padding(.horizontal, Slowly.Spacing.xl)
        }
    }
    .background(Slowly.Color.surfaceApp)
}

#Preview("Reflect selected") {
    VStack {
        Spacer()
        StatefulPreviewWrapper(TabBarMain.Tab.reflect) { selection in
            TabBarMain(selection: selection, onLog: {})
                .padding(.horizontal, Slowly.Spacing.xl)
        }
    }
    .background(Slowly.Color.surfaceApp)
}

// MARK: - Preview helper

/// Lightweight stateful wrapper for previewing components that take a Binding.
private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initial)
        self.content = content
    }

    var body: some View { content($value) }
}
