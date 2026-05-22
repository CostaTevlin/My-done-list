// BrandTabBar.swift
// Editorial navigation shell for iOS 18-25 (and macOS host build). On iOS 26
// `RootTabView` uses the native floating glass TabView instead — this fallback
// preserves brand fidelity where Liquid Glass isn't available, and is sized
// to feel as substantial as the native pill.
//
// Layout: floating pill container (Today · Reflect · More) + circle Log FAB,
// both on a single HStack so vertical centers always agree.
// Active state: tokenSurface filled capsule behind the icon+label. Touch targets ≥44pt.
// Respects Dynamic Type and Reduce Motion.
//
// Phase: 5 (token migration to sage palette)
// See: design-system/Components.md (BrandTabBar)  ·  ADR-0006 (Two-branch shell)

import SwiftUI

public struct BrandTabBar: View {
    public enum Tab: Hashable {
        case today
        case reflect
        case more
    }

    @Binding public var selection: Tab
    public let onLog: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(selection: Binding<Tab>, onLog: @escaping () -> Void) {
        self._selection = selection
        self.onLog = onLog
    }

    public var body: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            // Floating pill container holding the three nav tabs.
            // Expands to fill available width so the pill spans most of
            // the bar (matches the iOS 26 native floating pill proportions);
            // tab items inside share that width equally.
            HStack(spacing: 0) {
                tabItem(.today,   label: "Today",   icon: "calendar.badge.checkmark")
                tabItem(.reflect, label: "Reflect", icon: "chart.bar.xaxis")
                tabItem(.more,    label: "More",    icon: "ellipsis")
            }
            .padding(Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.borderDefault)
            )

            // Circle Log FAB — brand tokenInk, tokenSurface plus.
            // Lifted above the pill so the FAB-to-pill gap matches the
            // pill-to-screen-bottom margin (`Spacing.lg`). The offset value
            // = pill_height/2 + FAB_height/2 + gap
            //   ≈ 38.5  + 30 + 16  = ~85pt.
            // Centers can't be perfectly aligned with the pill in this
            // layout, so we go the other way and float the FAB clearly
            // above the bar (matching iOS 26's floating accessory feel).
            Button(action: onLog) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.surfaceApp)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.textPrimary)
                            .shadow(color: Color.textPrimary.opacity(0.18), radius: 10, y: 4)
                    )
            }
            .offset(y: -85)
            .accessibilityLabel("Log something you did")
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.lg)
        .background(Color.surfaceApp)
    }

    private func tabItem(_ tab: Tab, label: String, icon: String) -> some View {
        Button(action: { selection = tab }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(selection == tab ? Color.textPrimary : Color.textSecondary)
                Text(label)
                    .font(.label)
                    .foregroundStyle(selection == tab ? Color.textPrimary : Color.textSecondary)
            }
            .padding(.vertical, Spacing.sm + 2)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background {
                if selection == tab {
                    Capsule(style: .continuous)
                        .fill(Color.surfaceApp)
                        .shadow(color: Color.textPrimary.opacity(0.06), radius: 4, y: 1)
                }
            }
            .contentShape(Rectangle())
        }
        .accessibilityLabel("\(label) tab")
        .accessibilityAddTraits(selection == tab ? .isSelected : [])
        .buttonStyle(PlainButtonStyle())
        .animation(reduceMotion ? .none : Motion.snappy, value: selection)
    }
}

