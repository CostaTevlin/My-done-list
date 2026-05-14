// TodayView.swift
// The hero screen. Greeting · activity ring + counter · motivational copy · today's items.
// ADR-0010: onLogTap replaced by onLog(InputMode) + onEditItem(DoneItem).
// GhostInputRow appears above the item list (populated state) and replaces the pill CTA
// in empty state.
//
// Container note: native `.swipeActions` (ADR-0007) requires a `List`.
// We use a single `List` with hidden separators + clear backgrounds.
//
// Phase: 3, updated Phase 5 (Hero component), updated Phase 4.5 (ADR-0010 callbacks)
// See: design-system/Screen specs.md (Today)  ·  Copy bank.md  ·  ADR-0007  ·  ADR-0011

import SwiftUI
import SwiftData
import DesignSystem

struct TodayView: View {

    // MARK: - Environment

    @Environment(DoneStore.self) private var store
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \DoneItem.createdAt, order: .reverse) private var allItems: [DoneItem]

    /// Called when user taps the ghost row or empty-state CTA.
    /// Passes the desired InputMode (voice or text).
    var onLog: (InputMode) -> Void = { _ in }

    /// Called when user taps an existing item row to edit it.
    var onEditItem: (DoneItem) -> Void = { _ in }

    // MARK: - Derived state

    private var todayItems: [DoneItem] {
        allItems.filter { $0.date == store.todayKeyValue }
    }

    private var hour: Int {
        Calendar.current.component(.hour, from: .now)
    }

    private var greeting: String { CopyBank.greeting(hour: hour) }

    private var threshold: Int {
        InsightsEngine.rollingMedianThreshold(in: modelContext)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if todayItems.isEmpty {
                    emptyState
                } else {
                    populatedList
                }
            }
            .background(Color.tokenSurface.ignoresSafeArea())
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Populated list

    @ViewBuilder
    private var populatedList: some View {
        List {
            // Header — Hero block
            header
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 20, leading: Spacing.xxl, bottom: 30, trailing: Spacing.xxl))
                .listRowBackground(Color.tokenSurface)

            // Thin divider between hero and content
            Rectangle()
                .fill(Color.tokenMist)
                .frame(height: 1)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: Spacing.xxl, bottom: 0, trailing: Spacing.xxl))
                .listRowBackground(Color.tokenSurface)

            // GhostInputRow — persistent text-mode entry point above the item list
            GhostInputRow { onLog(.text) }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: Spacing.md, leading: Spacing.xxl, bottom: Spacing.md, trailing: Spacing.xxl))
                .listRowBackground(Color.tokenSurface)

            // Items
            ForEach(Array(todayItems.enumerated()), id: \.element.persistentModelID) { offset, item in
                let rank = todayItems.count - offset
                let isLast = offset == todayItems.count - 1

                ItemRow(
                    rank: rank,
                    text: item.text,
                    time: item.time,
                    showsDivider: !isLast,
                    onTap: { onEditItem(item) }
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: Spacing.xxl, bottom: 0, trailing: Spacing.xxl))
                .listRowBackground(Color.tokenSurface)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation(reduceMotion ? nil : Motion.snappy) {
                            store.delete(item)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .transition(rowTransition(index: offset))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.tokenSurface)
        .contentMargins(.bottom, Spacing.bottomSafe, for: .scrollContent)
        .animation(reduceMotion ? nil : Motion.entranceCurve, value: todayItems.count)
    }

    // MARK: - Header (Hero block)

    @ViewBuilder
    private var header: some View {
        Hero(
            variant: .today(count: todayItems.count, threshold: threshold),
            label: greeting.uppercased(),
            headline: "My done list",
            subtext: CopyBank.todayHeroInsight(count: todayItems.count, hour: hour)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Spacer().frame(height: Spacing.xxxl * 2)

                Text("Your day starts here")
                    .font(.displaySub)
                    .foregroundStyle(Color.tokenInk)

                Text("What's one thing you've already done today? Even getting out of bed counts.")
                    .font(.bodySub)
                    .foregroundStyle(Color.tokenSlate)
                    .frame(maxWidth: 260, alignment: .leading)

                Spacer().frame(height: Spacing.lg)

                // GhostInputRow replaces the old "Log something" pill CTA (ADR-0010)
                GhostInputRow { onLog(.text) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, 20)
            .padding(.bottom, Spacing.bottomSafe)
        }
    }

    // MARK: - Row entrance transition

    private func rowTransition(index: Int) -> AnyTransition {
        guard !reduceMotion else { return .identity }
        return .opacity.combined(with: .offset(y: 8))
    }
}

// MARK: - Previews

#Preview("Empty") {
    TodayView()
        .modelContainer(for: DoneItem.self, inMemory: true)
        .environment({
            DoneStore()
        }())
}

#Preview("Populated") {
    let container: ModelContainer = {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: DoneItem.self, configurations: cfg)
        let ctx = c.mainContext
        let today = DoneStore.todayKey()
        ctx.insert(DoneItem(text: "Took a 10-min walk", time: "14:32", date: today, createdAt: .now))
        ctx.insert(DoneItem(text: "Finished the budget spreadsheet", time: "13:15", date: today,
                            createdAt: .now.addingTimeInterval(-600)))
        ctx.insert(DoneItem(text: "Replied to overdue emails", time: "10:02", date: today,
                            createdAt: .now.addingTimeInterval(-7200)))
        return c
    }()

    return TodayView()
        .modelContainer(container)
        .environment(DoneStore(context: container.mainContext))
}
