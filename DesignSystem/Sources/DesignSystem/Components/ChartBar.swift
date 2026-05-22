// ChartBar.swift
// One day column in Reflect's weekly chart: count label · fill bar in a 14pt
// rounded track · day label. Today's bar uses tokenInk; previous days with
// activity use tokenMist; empty days draw nothing inside the track.
//
// Phase: 5 (token migration to sage palette)
// See: design-system/Components.md (ChartBar)
//      index.html lines 705-792 (PWA reference)
//
// Note: #Preview blocks live in the app target's call sites, not here, so the
// SwiftPM package can compile without Xcode's Previews plugin.

import SwiftUI

public struct ChartBar: View {
    public let count: Int
    public let label: String
    public let isToday: Bool
    /// 0…1 height ratio. The view itself does not divide by `maxCount` —
    /// the host computes the fraction so the whole row scales together.
    public let fraction: Double

    /// Total track height (PWA used 120pt).
    public static let trackHeight: CGFloat = 120

    /// Bar visual width (PWA used 28pt).
    public static let barWidth: CGFloat = 28

    public init(count: Int, label: String, isToday: Bool, fraction: Double) {
        self.count = count
        self.label = label
        self.isToday = isToday
        self.fraction = fraction
    }

    private var hasActivity: Bool { count > 0 }

    private var countColor: Color {
        if isToday { return .textPrimary }
        return hasActivity ? .textPrimary : .textSecondary.opacity(0.6)
    }

    private var barColor: Color {
        if isToday { return .textPrimary }
        return hasActivity ? .borderDefault : .clear
    }

    private var labelColor: Color {
        isToday ? .textPrimary : .textSecondary.opacity(0.6)
    }

    private var barFraction: CGFloat {
        // Min visible nub of 4pt for empty days mirrors PWA `Math.max(…, 4)`.
        // Empty days then hide the fill via `.clear` — the nub stays in layout
        // so all tracks have a baseline.
        let clamped = min(max(fraction, 0), 1)
        let minNub: CGFloat = 4 / Self.trackHeight
        return CGFloat(clamped > 0 ? max(clamped, minNub) : minNub)
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text("\(count)")
                .font(.chartCount)
                .foregroundStyle(countColor)
                .padding(.bottom, Spacing.sm)
                .accessibilityHidden(true)

            // Track
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .fill(Color.surfaceApp)

                // Fill bar — grows from the bottom, capped to the track radius.
                GeometryReader { proxy in
                    let h = proxy.size.height * barFraction
                    RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                        .fill(barColor)
                        .frame(
                            width: proxy.size.width,
                            height: h,
                            alignment: .bottom
                        )
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .bottom
                        )
                }
            }
            .frame(width: Self.barWidth, height: Self.trackHeight)

            Text(label)
                .font(.chartDayLabel)
                .fontWeight(isToday ? .semibold : .regular)
                .foregroundStyle(labelColor)
                .padding(.top, Spacing.sm)
                .accessibilityHidden(true)
        }
        // Column itself flexes — the host (a row HStack) decides how much
        // horizontal room each one gets. The 28pt track sits centered
        // inside whatever width is granted.
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(count) \(count == 1 ? "thing" : "things") logged")
    }
}
