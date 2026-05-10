// Hero.swift
// Top hero block for Today and Reflect screens.
// Two variants via enum — not two separate components.
// Phase: 5 · See: design-system/Components.md (Hero) · Phase 5 hero contract §6

import SwiftUI

public struct Hero: View {
    public enum Variant: Equatable {
        case today(count: Int, threshold: Int)
        case reflect
    }

    public let variant: Variant
    public let label: String
    public let headline: String
    public let subtext: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(variant: Variant, label: String, headline: String, subtext: String) {
        self.variant = variant
        self.label = label
        self.headline = headline
        self.subtext = subtext
    }

    private var isAccessibilitySize: Bool {
        dynamicTypeSize >= .accessibility1
    }

    public var body: some View {
        switch variant {
        case let .today(count, threshold):
            todayHero(count: count, threshold: threshold)
        case .reflect:
            reflectHero
        }
    }

    // MARK: - Today hero

    @ViewBuilder
    private func todayHero(count: Int, threshold: Int) -> some View {
        let progress = threshold > 0 ? Double(count) / Double(threshold) : 0
        let thingLabel = count == 1 ? "thing\ntoday" : "things\ntoday"

        VStack(alignment: .leading, spacing: 0) {
            labelView
            Spacer().frame(height: 8)
            headlineView
            Spacer().frame(height: 24)

            if isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    BigNumeral(value: count)
                        .animation(reduceMotion ? nil : Motion.snappy, value: count)
                    Text(thingLabel)
                        .font(.bodySub)
                        .foregroundStyle(Color.tokenSlate)
                    ActivityRing(progress: progress, diameter: 120, strokeWidth: 10)
                }
            } else {
                HStack(alignment: .center, spacing: 0) {
                    // Left half: number + label, anchored leading
                    HStack(alignment: .lastTextBaseline, spacing: 10) {
                        BigNumeral(value: count)
                            .animation(reduceMotion ? nil : Motion.snappy, value: count)
                            .fixedSize()
                        Text(thingLabel)
                            .font(.bodySub)
                            .foregroundStyle(Color.tokenSlate)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Right half: ring centered in its half
                    ActivityRing(progress: progress, diameter: 110, strokeWidth: 10)
                        .frame(maxWidth: .infinity)
                }
            }

            Spacer().frame(height: 15)
            insightRowView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label). \(count) \(count == 1 ? "thing" : "things") today. \(subtext)")
    }

    // MARK: - Reflect hero

    @ViewBuilder
    private var reflectHero: some View {
        ZStack(alignment: .topTrailing) {
            // Botanical image — behind text, bleeds 12pt off trailing edge
            Image("bg_reflect-1", bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 220)
                .padding(.trailing, -12)
                .zIndex(-1)
                .accessibilityHidden(true)

            // Text content constrained to left ~58%
            VStack(alignment: .leading, spacing: 0) {
                labelView
                Spacer().frame(height: 8)

                Text(headline)
                    .font(.display)
                    .foregroundStyle(Color.tokenInk)
                    .frame(maxWidth: 220, alignment: .leading)

                Spacer().frame(height: 20)

                Text(subtext)
                    .font(.motivational)
                    .foregroundStyle(Color.tokenSlate)
                    .lineLimit(2)
                    .frame(maxWidth: 220, alignment: .leading)
                    .id(subtext)
                    .transition(.opacity)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: subtext)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label). \(headline). \(subtext)")
    }

    // MARK: - Shared subviews

    private var labelView: some View {
        Text(label)
            .font(.label)
            .kerning(TypographyKerning.label)
            .foregroundStyle(Color.tokenSlate)
    }

    private var headlineView: some View {
        Text(headline)
            .font(.display)
            .foregroundStyle(Color.tokenInk)
    }

    private var insightView: some View {
        Text(subtext)
            .font(.motivational)
            .foregroundStyle(Color.tokenSlate)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .id(subtext)
            .transition(.opacity)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: subtext)
    }

    private var insightRowView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(subtext)
                .font(.motivational)
                .foregroundStyle(Color.tokenSlate)
                .lineLimit(2)
                .id(subtext)
                .transition(.opacity)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: subtext)
            Spacer()
            Image(systemName: "heart.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.tokenSage600)
        }
        .frame(maxWidth: .infinity)
    }
}
