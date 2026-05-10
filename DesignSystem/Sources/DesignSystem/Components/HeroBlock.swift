// HeroBlock.swift
// 3-line hero block for the Today screen: count · supporting label · insight line.
// Pure presentation — no business logic, no SwiftData dependency.
//
// Phase: 5 (ADR-0011 — ADHD-first repositioning; token migration to sage palette)
// See: design-system/Screen specs.md §1 · design-system/Copy bank.md v2 · ADR-0011

import SwiftUI

public struct HeroBlock: View {
    public let count: Int
    public let supportingLabel: String
    public let insight: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(count: Int, supportingLabel: String, insight: String) {
        self.count = count
        self.supportingLabel = supportingLabel
        self.insight = insight
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BigNumeral(value: count)
                .animation(reduceMotion ? nil : Motion.snappy, value: count)

            Spacer().frame(height: Spacing.sm)      // 8pt — label sits close below numeral

            Text(supportingLabel)
                .font(.bodySub)
                .foregroundStyle(Color.tokenSlate)

            Spacer().frame(height: Spacing.lg)      // 16pt — visual separation before insight

            Text(insight)
                .font(.motivational)
                .foregroundStyle(Color.tokenInk)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .frame(maxWidth: 260, alignment: .leading)
                .id(insight)
                .transition(.opacity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: insight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(count) \(count == 1 ? "thing" : "things") today. \(insight)")
    }
}
