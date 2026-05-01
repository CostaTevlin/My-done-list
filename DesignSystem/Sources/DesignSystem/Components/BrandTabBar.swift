// BrandTabBar.swift
// Editorial navigation shell for iOS 18-25. Replaces native TabView to preserve
// brand typographic confidence — avoids Liquid Glass system tint that destroys
// the monochrome design language. On iOS 26, RootTabView uses native TabView with
// charcoal tint instead.
//
// Layout: HStack of Today label · "+ Log" pill · Reflect label, all full-width.
// Active state: uppercase label + animated charcoal underline. Touch targets ≥44pt.
// Respects Dynamic Type and Reduce Motion.
//
// Phase: 1 (iOS 18-25 fallback), 3 (shell refactor)
// See: design-system/Components.md (BrandTabBar)  ·  design-system/Liquid Glass mapping.md
//      ADR-0006 (Two-branch shell)

import SwiftUI

public struct BrandTabBar: View {
    public enum Tab: Hashable {
        case today
        case reflect
    }

    @Binding public var selection: Tab
    public let onLog: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(selection: Binding<Tab>, onLog: @escaping () -> Void) {
        self._selection = selection
        self.onLog = onLog
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top divider
            Rectangle()
                .fill(Color.tokenBorderLight)
                .frame(height: 1)

            HStack(spacing: 0) {
                // MARK: - Today slot
                todaySlot
                    .frame(maxWidth: .infinity)

                // MARK: - Center pill
                Button(action: onLog) {
                    Text("+ Log")
                        .font(.tokenBody.weight(.medium))
                }
                .brandPillStyle()
                .accessibilityLabel("Log something you did")

                // MARK: - Reflect slot
                reflectSlot
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.lg)
            .padding(.bottom, Spacing.sm)
            .background(Color.tokenWhite)
        }
    }

    private var todaySlot: some View {
        Button(action: { selection = .today }) {
            VStack(spacing: 4) {
                Text("Today")
                    .font(.tokenLabel)
                    .kerning(TypographyKerning.label)
                    .textCase(.uppercase)
                    .foregroundStyle(selection == .today ? Color.tokenCharcoal : Color.tokenMid)

                if selection == .today {
                    Capsule()
                        .fill(Color.tokenCharcoal)
                        .frame(width: 24, height: 2)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 24, height: 2)
                }
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .accessibilityLabel("Today tab")
        .accessibilityAddTraits(selection == .today ? .isSelected : [])
        .buttonStyle(PlainButtonStyle())
        .animation(reduceMotion ? .none : Motion.snappy, value: selection)
    }

    private var reflectSlot: some View {
        Button(action: { selection = .reflect }) {
            VStack(spacing: 4) {
                Text("Reflect")
                    .font(.tokenLabel)
                    .kerning(TypographyKerning.label)
                    .textCase(.uppercase)
                    .foregroundStyle(selection == .reflect ? Color.tokenCharcoal : Color.tokenMid)

                if selection == .reflect {
                    Capsule()
                        .fill(Color.tokenCharcoal)
                        .frame(width: 24, height: 2)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 24, height: 2)
                }
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .accessibilityLabel("Reflect tab")
        .accessibilityAddTraits(selection == .reflect ? .isSelected : [])
        .buttonStyle(PlainButtonStyle())
        .animation(reduceMotion ? .none : Motion.snappy, value: selection)
    }
}

// MARK: - Preview

#Preview("Today selected") {
    @Previewable @State var selection: BrandTabBar.Tab = .today
    BrandTabBar(selection: $selection, onLog: {})
        .background(Color.tokenOffWhite)
}

#Preview("Reflect selected") {
    @Previewable @State var selection: BrandTabBar.Tab = .reflect
    BrandTabBar(selection: $selection, onLog: {})
        .background(Color.tokenOffWhite)
}
