// AdaptiveHero.swift
// Multi-state hero component used on Today, Reflect, and Empty screens.
// Adapts height automatically (SwiftUI auto-layout) as state changes.
// Backdrop: static PNG asset per ADR redesign-techdebt-001 (Figma intent: concave-arc photo + dark blur — see Components.md).
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › node 111:8965 (hero component set — Type=Compact | Expanded).
// Per Figma, BigNumeral is composed by the consuming screen above this hero — it is not rendered inside.
// Known deltas vs Figma 111:8965 — see Components.md › Hero (Adaptive) › "Implementation deltas":
//   - .empty state renders "No wins yet" + subtitle; Figma empty = title hidden, no text.
//   - Backdrop asset (navBarHero PNG) differs from Figma's concave-arc photo composition.

import SwiftUI

// MARK: - State

/// The three display states of the adaptive hero.
public enum HeroState: Equatable {
    /// Today screen with items. Shows date, headline, and subtitle.
    /// The BigNumeral is composed by the caller above this hero (per Figma 111:8965).
    case today(date: String, headline: String, subtitle: String)
    /// Reflect screen. Shows "Reflect" label, headline, and subtitle.
    case reflect(headline: String, subtitle: String)
    /// Empty state. Shows "No wins yet" and empty-state copy. No subtitle.
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
        case let .today(date, _, _):
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

    // State-specific headline
    private var headline: some View {
        Text(headlineText)
            .font(Slowly.Font.title1Light)
            .foregroundStyle(Slowly.Color.textPrimary)
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .transition(.opacity)
    }

    private var headlineText: String {
        switch state {
        case let .today(_, headline, _): return headline
        case let .reflect(headline, _):  return headline
        case .empty:                     return "No wins yet"
        }
    }

    // Subtitle — Today and Reflect only
    @ViewBuilder
    private var subtitleRow: some View {
        switch state {
        case let .today(_, _, subtitle),
             let .reflect(_, subtitle):
            Text(subtitle)
                .font(Slowly.Font.headlineRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .lineLimit(2)
                .transition(.opacity)
        case .empty:
            Text("Every small step counts.\nYou've got this.")
                .font(Slowly.Font.headlineRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .transition(.opacity)
        }
    }

    // MARK: - Accessibility

    // BigNumeral is composed by the caller and carries its own a11y label, so we
    // don't repeat the count here.
    private var a11yLabel: String {
        switch state {
        case let .today(_, headline, subtitle):
            return "\(headline). \(subtitle)"
        case let .reflect(headline, subtitle):
            return "Reflect. \(headline). \(subtitle)"
        case .empty:
            return "No wins yet. Every small step counts."
        }
    }
}

// MARK: - Preview

#Preview("Today — populated") {
    ScrollView {
        VStack(alignment: .leading, spacing: 0) {
            BigNumeral(value: 7)
                .padding(.horizontal, Slowly.Spacing.xl)
            AdaptiveHero(state: .today(
                date: "Monday, 18 May",
                headline: "You're on a roll now",
                subtitle: "Some motivational subtitle goes here maybe in two lines"
            ))
        }
    }
    .background(Slowly.Color.surfaceApp)
}

#Preview("Today — one item") {
    VStack(alignment: .leading, spacing: 0) {
        BigNumeral(value: 1)
            .padding(.horizontal, Slowly.Spacing.xl)
        AdaptiveHero(state: .today(
            date: "Monday, 18 May",
            headline: "Good start",
            subtitle: "One thing done is one thing done."
        ))
    }
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
