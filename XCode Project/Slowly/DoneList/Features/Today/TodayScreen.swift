// TodayScreen.swift
// Today screen — R4 D3-composite (canonical, flag removed).
// Coordinator: hosts a single shared AdaptiveHero above content that swaps
// between EmptyTodayScreen (sprout/heading/arrow) and the populated List.
// Because the hero is one instance, its built-in `.animation(value: state)`
// interpolates the 300pt↔95pt height and content opacity smoothly when the
// first item is logged or the last is deleted.
// Navbar: trailing AccountButton opens SettingsView sheet.
//
// Phase: R5 (hero-animation refactor — hero hoisted from per-state screens)
// See: design-system/Screen specs.md (Today)  ·  ADR-0007 (swipeActions)  ·  ADR-0010
//      ADR-0011 (ADHD copy via CopyBank)  ·  ADR-0005 (Liquid Glass gating)

import SwiftUI
import SwiftData
import DesignSystem

struct TodayScreen: View {

    // MARK: - Environment

    @Environment(DoneStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // Fetches all rows then filters in Swift rather than using a #Predicate,
    // because @Query's predicate must be a compile-time constant but todayKeyValue
    // changes at midnight. The full table is pruned to ≤30 days, so this stays small.
    @Query(sort: \DoneItem.createdAt, order: .reverse) private var allItems: [DoneItem]

    var onLog: (InputMode) -> Void = { _ in }
    var onEditItem: (DoneItem) -> Void = { _ in }

    // MARK: - Local state

    @State private var showAccount = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                // Shared surface bleeds into the safe area so the hero's
                // watercolour has the same backdrop in either state.
                Slowly.Color.surfaceApp.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Single hero instance — switching state animates the
                    // 95pt↔300pt height via the hero's own .animation modifier.
                    AdaptiveHero(state: heroState)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Content below the hero fades + slides as the hero
                    // height changes. The transition is per-branch so the
                    // outgoing view fades out as the incoming one fades in.
                    if todayItems.isEmpty {
                        EmptyTodayScreen(onLog: onLog)
                            .transition(.opacity)
                    } else {
                        todayList
                            .transition(.opacity)
                    }
                }
                // Start the VStack from screen-top (y=0) so the hero occupies
                // 0–95pt from screen top — matching Figma's hero frame that
                // starts at y=0 of the canvas. Without this the VStack starts
                // at the safe-area inset (~59pt) making the hero bottom land at
                // ~154pt and leaving a large gap before the date text.
                .ignoresSafeArea(edges: .top)
            }
            // Animate the empty↔populated swap. The hero's height interpolates
            // (via its own animation), the VStack re-layouts its children, and
            // the if/else branches cross-fade via the .opacity transition.
            .animation(
                reduceMotion ? nil : .spring(duration: 0.45, bounce: 0.15),
                value: todayItems.isEmpty
            )
            // Force the nav bar to render so the trailing AccountButton is laid out.
            // Without `.toolbar(.visible, ...)`, SwiftUI on iOS 26 inside a `Tab`
            // collapses the bar entirely when the title is empty and the background
            // is hidden — taking the toolbar item with it (verified empirically).
            .toolbar(.visible, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AccountButton { showAccount = true }
                }
            }
        }
        .sheet(isPresented: $showAccount) {
            NavigationStack { SettingsView() }
        }
    }

    // MARK: - Derived state

    private var todayItems: [DoneItem] {
        allItems.filter { $0.date == store.todayKeyValue }
    }

    private var hour: Int {
        Calendar.current.component(.hour, from: .now)
    }

    // MARK: - Time-of-day sectioning

    private enum Period: Int, CaseIterable {
        case evening   = 2
        case afternoon = 1
        case morning   = 0

        var label: String {
            switch self {
            case .morning:   return "Morning"
            case .afternoon: return "Afternoon"
            case .evening:   return "Evening"
            }
        }

        static func from(time: String) -> Period {
            guard let h = Int(time.prefix(2)) else { return .morning }
            if h >= 18 { return .evening }
            if h >= 12 { return .afternoon }
            return .morning
        }
    }

    private struct ItemSection: Identifiable {
        let period: Period
        let items: [DoneItem]
        var id: Int { period.rawValue }
    }

    private var sections: [ItemSection] {
        let grouped = Dictionary(grouping: todayItems, by: { Period.from(time: $0.time) })
        // allCases returns cases in declaration order: evening(2) → afternoon(1) → morning(0).
        // The sort is intentionally omitted — declaration order is the canonical order here.
        return Period.allCases
            .compactMap { period -> ItemSection? in
                guard let items = grouped[period], !items.isEmpty else { return nil }
                return ItemSection(period: period, items: items)
            }
    }

    // MARK: - Hero

    // Uses system locale intentionally — the hero date is a display string for the user,
    // so it should respect their locale. Unlike DoneStore formatters (which force POSIX
    // for key generation), this one is purely decorative.
    private static let heroDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, d MMM"
        return f
    }()

    // Hero state derives from item count so a single AdaptiveHero instance can
    // animate its 300pt↔95pt height when the user logs their first item or
    // deletes their last. .empty is the Expanded variant; .today(...) is Compact.
    private var heroState: HeroState {
        if todayItems.isEmpty {
            return .empty
        }
        return .today(
            date: Self.heroDateFormatter.string(from: .now),
            headline: CopyBank.message(count: todayItems.count, hour: hour),
            subtitle: CopyBank.todayHeroInsight(count: todayItems.count, hour: hour)
        )
    }

    // MARK: - Today list (populated branch — sits below the shared hero)

    @ViewBuilder
    private var todayList: some View {
        List {
            // Title block sits below the hero band, on the plain surface
            // (Figma 112:9687): date · BigNumeral · headline · subtitle.
            todayTitleBlock
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: Slowly.Spacing.xxxl,
                    leading: 0,
                    bottom: Slowly.Spacing.lg,
                    trailing: 0
                ))
                .listRowBackground(Slowly.Color.surfaceApp)

            // Time-of-day sections
            ForEach(sections) { section in
                // Section header
                TimeOfDaySectionHeader(label: section.period.label, count: section.items.count)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(
                        top: Slowly.Spacing.lg,
                        leading: Slowly.Spacing.xl,
                        bottom: Slowly.Spacing.xs,
                        trailing: Slowly.Spacing.xl
                    ))
                    .listRowBackground(Slowly.Color.surfaceApp)

                // Rows
                ForEach(Array(section.items.enumerated()), id: \.element.persistentModelID) { index, item in
                    EntryRow(
                        text: item.text,
                        timestamp: item.time,
                        isLast: index == section.items.count - 1,
                        isVoiceCaptured: item.source == .voice,
                        onMenu: { onEditItem(item) }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(
                        top: 0,
                        leading: Slowly.Spacing.xl,
                        bottom: 0,
                        trailing: Slowly.Spacing.xl
                    ))
                    .listRowBackground(Slowly.Color.surfaceApp)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation(reduceMotion ? nil : Motion.snappy) {
                                store.delete(item)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        // Remove the automatic top inset that NavigationStack injects so the
        // List's scroll content clears the (hidden) nav bar. Without this, the
        // first row is pushed ~100pt below the hero, leaving a large empty gap.
        .contentMargins(.top, 0, for: .scrollContent)
        .contentMargins(.bottom, Slowly.Spacing.screenBottom, for: .scrollContent)
        .animation(reduceMotion ? nil : Motion.entranceCurve, value: todayItems.count)
    }

    // MARK: - Today title block (composed below the compact hero, per Figma 112:9687)

    @ViewBuilder
    private var todayTitleBlock: some View {
        VStack(alignment: .leading, spacing: Slowly.Spacing.sm) {
            Text(Self.heroDateFormatter.string(from: .now))
                .font(Slowly.Font.bodyMedium)
                .foregroundStyle(Slowly.Color.textSecondary)

            BigNumeral(value: todayItems.count)

            Text(CopyBank.message(count: todayItems.count, hour: hour))
                .font(Slowly.Font.title1Light)
                .foregroundStyle(Slowly.Color.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)

            Text(CopyBank.todayHeroInsight(count: todayItems.count, hour: hour))
                .font(Slowly.Font.headlineRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .lineLimit(2)
        }
        .padding(.horizontal, Slowly.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

#Preview("Empty") {
    TodayScreen()
        .modelContainer(for: DoneItem.self, inMemory: true)
        .environment(DoneStore())
}

#Preview("Populated — mixed time buckets") {
    let container: ModelContainer = {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: DoneItem.self, configurations: cfg)
        let ctx = c.mainContext
        let today = DoneStore.todayKey()
        ctx.insert(DoneItem(text: "Replied to overdue emails", time: "09:15", date: today, source: .text))
        ctx.insert(DoneItem(text: "Finished the deck", time: "14:30", date: today, source: .voice))
        ctx.insert(DoneItem(text: "Reviewed pull requests", time: "15:00", date: today, source: .text))
        ctx.insert(DoneItem(text: "Took a 10-min walk", time: "19:45", date: today, source: .voice))
        return c
    }()
    return TodayScreen()
        .modelContainer(container)
        .environment(DoneStore(context: container.mainContext))
}
