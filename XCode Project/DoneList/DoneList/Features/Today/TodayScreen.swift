// TodayScreen.swift
// Today screen — R4 D3-composite (canonical, flag removed).
// Coordinator: branches on item count between populated list and EmptyTodayScreen.
// Populated path: AdaptiveHero + time-of-day sections (TimeOfDaySectionHeader + EntryRow).
// Navbar: persistent native nav bar with trailing AccountButton → SettingsView sheet.
//
// Phase: R4
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
            Group {
                if todayItems.isEmpty {
                    EmptyTodayScreen(onLog: onLog)
                } else {
                    populatedList
                }
            }
            .background(Slowly.Color.surfaceApp.ignoresSafeArea())
            // Force the nav bar to render so the trailing AccountButton is laid out.
            // Without `.toolbar(.visible, ...)`, SwiftUI on iOS 26 inside a `Tab`
            // collapses the bar entirely when the title is empty and the background
            // is hidden — taking the toolbar item with it (verified empirically).
            .toolbar(.visible, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
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

    private var heroState: HeroState {
        .today(
            date: Self.heroDateFormatter.string(from: .now),
            count: todayItems.count,
            headline: CopyBank.message(count: todayItems.count, hour: hour),
            subtitle: CopyBank.todayHeroInsight(count: todayItems.count, hour: hour)
        )
    }

    // MARK: - Populated list

    @ViewBuilder
    private var populatedList: some View {
        List {
            // Hero — full-bleed; manages its own horizontal + top padding internally
            AdaptiveHero(state: heroState)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: Slowly.Spacing.lg, trailing: 0))
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
        .background(Slowly.Color.surfaceApp)
        .contentMargins(.bottom, Slowly.Spacing.screenBottom, for: .scrollContent)
        .animation(reduceMotion ? nil : Motion.entranceCurve, value: todayItems.count)
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
