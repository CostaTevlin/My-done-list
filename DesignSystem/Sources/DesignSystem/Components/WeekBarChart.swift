// WeekBarChart.swift
// 7-column weekly bar chart composite — wraps ChartBar instances.
// Hand-built (no Charts framework dependency); decision: D3 contract §WeekBarChart.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › D0 Experience › Reflect screen chart

import SwiftUI

// MARK: - Day model

public extension WeekBarChart {
    /// One day's data for the chart.
    struct Day {
        public let label: String
        public let count: Int
        public let isToday: Bool

        public init(label: String, count: Int, isToday: Bool = false) {
            self.label = label
            self.count = count
            self.isToday = isToday
        }
    }
}

// MARK: - Component

/// Horizontal row of 7 `ChartBar` columns scaled to the week's maximum count.
/// All bars share the same max so they're visually comparable.
public struct WeekBarChart: View {

    public let days: [Day]

    public init(days: [Day]) {
        self.days = days
    }

    private var maxCount: Int {
        max(days.map(\.count).max() ?? 0, 1) // avoid division by zero
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                ChartBar(
                    count: day.count,
                    label: day.label,
                    isToday: day.isToday,
                    fraction: Double(day.count) / Double(maxCount)
                )
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview("Normal week") {
    WeekBarChart(days: [
        .init(label: "Wed", count: 2),
        .init(label: "Thu", count: 5),
        .init(label: "Fri", count: 1),
        .init(label: "Sat", count: 4),
        .init(label: "Sun", count: 0),
        .init(label: "Mon", count: 3),
        .init(label: "Today", count: 7, isToday: true),
    ])
    .padding(Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}

#Preview("All zeros") {
    WeekBarChart(days: (0..<7).map { i in
        .init(label: "D\(i)", count: 0)
    })
    .padding(Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}

#Preview("Single spike") {
    WeekBarChart(days: [
        .init(label: "Mon", count: 0),
        .init(label: "Tue", count: 0),
        .init(label: "Wed", count: 12),
        .init(label: "Thu", count: 0),
        .init(label: "Fri", count: 0),
        .init(label: "Sat", count: 0),
        .init(label: "Today", count: 1, isToday: true),
    ])
    .padding(Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}
