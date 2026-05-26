// AdaptiveHero.swift
// Multi-state hero component used on Today, Reflect, and Empty screens.
// Adapts height automatically (SwiftUI auto-layout) as state changes.
// Botanical illustration: static PNG asset per ADR redesign-techdebt-001.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › node 17:2491 (hero component)

import SwiftUI

// MARK: - State

/// The three display states of the adaptive hero.
public enum HeroState: Equatable {
    /// Today screen with items. Shows date, big count, headline, and subtitle.
    case today(date: String, count: Int, headline: String, subtitle: String)
    /// Reflect screen. Shows "Reflect" label, headline, and subtitle. No numeral.
    case reflect(headline: String, subtitle: String)
    /// Empty state. Backdrop only — no eyebrow, headline, or subtitle.
    /// Matches Figma `111:8965` variant `Type=Expanded` with title hidden.
    /// Decorative: the screen-level empty hint (e.g. `EmptyStateArrow`) carries the guidance.
    case empty
}

// MARK: - Component

/// Adaptive hero header shared across Today, Reflect, and Empty screens.
/// Height is content-driven — grows/shrinks as state changes.
/// Botanical illustration floats behind content; it is decorative and VoiceOver-hidden.
public struct AdaptiveHero: View {

    public let state: HeroState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(state: HeroState) {
        self.state = state
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            botanicalLayer
            contentStack
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(reduceMotion ? nil : .spring(duration: 0.4, bounce: 0.1), value: state)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yLabel)
        .accessibilityHidden(state == .empty)
    }

    // MARK: - Botanical illustration

    // per ADR redesign-techdebt-001 — raster asset, not native SwiftUI paths
    @ViewBuilder
    private var botanicalLayer: some View {
        Image("navBarHero", bundle: .module)
            .resizable()
            .scaledToFill()
            .frame(height: illustrationHeight)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .clipped()
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    private var illustrationHeight: CGFloat {
        switch state {
        case .today, .reflect: return 200
        case .empty:           return 300
        }
    }

    // MARK: - Text content

    private var contentStack: some View {
        VStack(alignment: .leading, spacing: Slowly.Spacing.sm) {
            topLabel
            numeralRow
            headline
            subtitleRow
        }
        .padding(.horizontal, Slowly.Spacing.xl)
        .padding(.top, Slowly.Spacing.screenTop)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Date string (Today/Empty) or "Reflect" label
    @ViewBuilder
    private var topLabel: some View {
        switch state {
        case let .today(date, _, _, _):
            Text(date)
                .font(Slowly.Font.bodyMedium)
                .foregroundStyle(Slowly.Color.textSecondary)
        case .reflect:
            Text("Reflect")
                .font(Slowly.Font.bodyMedium)
                .foregroundStyle(Slowly.Color.textSecondary)
        case .empty:
            EmptyView()
        }
    }

    // Big numeral — Today only
    @ViewBuilder
    private var numeralRow: some View {
        if case let .today(_, count, _, _) = state {
            Text("\(count)")
                .font(Slowly.Font.bigNumeral)
                .monospacedDigit()
                .foregroundStyle(Slowly.Color.textPrimary)
                .contentTransition(.numericText())
                .animation(reduceMotion ? nil : .spring(duration: 0.3), value: count)
        }
    }

    // State-specific headline — Today and Reflect only; empty hides the title block per Figma 111:8965
    @ViewBuilder
    private var headline: some View {
        switch state {
        case let .today(_, _, headline, _),
             let .reflect(headline, _):
            Text(headline)
                .font(Slowly.Font.title1Light)
                .foregroundStyle(Slowly.Color.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .transition(.opacity)
        case .empty:
            EmptyView()
        }
    }

    // Subtitle — Today and Reflect only; empty hides the title block per Figma 111:8965
    @ViewBuilder
    private var subtitleRow: some View {
        switch state {
        case let .today(_, _, _, subtitle),
             let .reflect(_, subtitle):
            Text(subtitle)
                .font(Slowly.Font.headlineRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .lineLimit(2)
                .transition(.opacity)
        case .empty:
            EmptyView()
        }
    }

    // MARK: - Accessibility

    private var a11yLabel: String {
        switch state {
        case let .today(_, count, headline, subtitle):
            return "\(count) \(count == 1 ? "thing" : "things") today. \(headline). \(subtitle)"
        case let .reflect(headline, subtitle):
            return "Reflect. \(headline). \(subtitle)"
        case .empty:
            // Hero is `.accessibilityHidden(true)` in `.empty`; label is unread but kept defensively.
            return ""
        }
    }
}

// MARK: - Preview

#Preview("Today — populated") {
    ScrollView {
        AdaptiveHero(state: .today(
            date: "Monday, 18 May",
            count: 7,
            headline: "You're on a roll now",
            subtitle: "Some motivational subtitle goes here maybe in two lines"
        ))
    }
    .background(Slowly.Color.surfaceApp)
}

#Preview("Today — one item") {
    AdaptiveHero(state: .today(
        date: "Monday, 18 May",
        count: 1,
        headline: "Good start",
        subtitle: "One thing done is one thing done."
    ))
    .background(Slowly.Color.surfaceApp)
}

#Preview("Reflect") {
    AdaptiveHero(state: .reflect(
        headline: "What a great week",
        subtitle: "Some motivational subtitle."
    ))
    .background(Slowly.Color.surfaceApp)
}

#Preview("Empty") {
    AdaptiveHero(state: .empty)
        .background(Slowly.Color.surfaceApp)
}
