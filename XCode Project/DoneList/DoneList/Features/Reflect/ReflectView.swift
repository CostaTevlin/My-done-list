// ReflectView.swift
// Weekly bar chart + today's timeline + reflection note.
//
// Layout (top to bottom): Hero(reflect) · "This week" weekly chart ·
// rule · chronological timeline (earliest first, time + text rows) ·
// "X things done today" · "See you tomorrow".
//
// Phase: 5 (Hero integration + token migration to sage palette)
// See: design-system/Screen specs.md (Reflect)  · design-system/Components.md (ChartBar)
//      index.html lines 688-825 (PWA parity reference)

import SwiftUI
import SwiftData
import DesignSystem

struct ReflectView: View {

    // MARK: - Environment

    @Environment(DoneStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \DoneItem.createdAt, order: .reverse) private var allItems: [DoneItem]
    @State private var selectedDayOffset: Int? = nil    // 0 = today, negative = past days

    // MARK: - Derived state

    /// Today's items ordered earliest → latest, matching the PWA's "timeline".
    private var timeline: [DoneItem] {
        let cal = Calendar.current
        let base = Date.now
        let targetDate: Date
        if let offset = selectedDayOffset {
            targetDate = cal.date(byAdding: .day, value: offset, to: base) ?? base
        } else {
            targetDate = base
        }
        let key = DoneStore.todayKey(now: targetDate)
        return allItems
            .filter { $0.date == key }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var todayCount: Int { timeline.count }

    private var weekData: [DoneStore.WeekDay] {
        DoneStore.weekData(items: allItems)
    }

    private var hour: Int {
        Calendar.current.component(.hour, from: .now)
    }

    private var reflectNote: String {
        CopyBank.reflectNote(count: todayCount, hour: hour)
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroBlock
                weeklyChart
                divider
                timelineSection
                footer
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.xxl)
            .padding(.top, 20)
            .padding(.bottom, Spacing.bottomSafe)
        }
        .background(Color.surfaceApp.ignoresSafeArea())
    }

    // MARK: - Hero block

    @ViewBuilder
    private var heroBlock: some View {
        Hero(
            variant: .reflect,
            label: "REFLECT",
            headline: "Your day so far",
            subtext: reflectNote
        )
        Spacer().frame(height: 32)
    }

    // MARK: - Weekly chart

    @ViewBuilder
    private var weeklyChart: some View {
        Text("This week")
            .font(.label)
            .kerning(TypographyKerning.label)
            .textCase(.uppercase)
            .foregroundStyle(Color.textSecondary.opacity(0.6))

        Spacer().frame(height: Spacing.lg)

        let week = weekData
        let maxCount = max(week.map(\.count).max() ?? 0, 1)

        // 7 columns flex to fill the strip — mirrors the PWA's
        // `display:flex; flex: 1 0 44px` so "Today" never gets clipped.
        let todayIndex: Int = week.firstIndex(where: { $0.isToday }) ?? max(week.count - 1, 0)

        HStack(alignment: .bottom, spacing: Spacing.sm) {
            ForEach(Array(week.enumerated()), id: \.offset) { pair in
                let idx = pair.offset
                let day = pair.element
                let dayCount: Int = day.count
                let fraction: Double = Double(dayCount) / Double(maxCount)
                let offset: Int = idx - todayIndex   // today = 0
                let isSelected: Bool = (selectedDayOffset == offset)

                WeeklyBarCell(
                    count: dayCount,
                    label: day.label,
                    isToday: day.isToday,
                    fraction: fraction,
                    isSelected: isSelected,
                    reduceMotion: reduceMotion,
                    onTap: {
                        if selectedDayOffset == offset {
                            selectedDayOffset = nil
                        } else {
                            selectedDayOffset = offset
                        }
                    }
                )
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Past 7 days")
    }

    // MARK: - Divider

    @ViewBuilder
    private var divider: some View {
        Spacer().frame(height: 32)
        Rectangle()
            .fill(Color.borderDefault)
            .frame(height: 1)
    }

    // MARK: - Timeline (chronological)

    @ViewBuilder
    private var timelineSection: some View {
        if timeline.isEmpty {
            Spacer().frame(height: 48)
            Text(selectedDayOffset == nil ? "Nothing to reflect on yet. Go to Today and log your first win." : "No items for that day.")
                .font(.bodyText)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer().frame(height: 48)
        } else {
            Spacer().frame(height: 20)
            if selectedDayOffset != nil {
                Button("Clear filter") { selectedDayOffset = nil }
                    .font(Font.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.textSecondary.opacity(0.6))
                    .padding(.bottom, Spacing.sm)
            }
            VStack(spacing: 0) {
                ForEach(Array(timeline.enumerated()), id: \.element.persistentModelID) { offset, item in
                    let isLast = offset == timeline.count - 1
                    timelineRow(time: item.time, text: item.text, showsDivider: !isLast)
                }
            }
            Spacer().frame(height: Spacing.xl)
            Text("\(todayCount) \(todayCount == 1 ? "thing" : "things") done \(selectedDayOffset == nil ? "today" : "that day")")
                .font(Font.system(size: 13, weight: .regular))
                .foregroundStyle(Color.textSecondary.opacity(0.6))
        }
    }

    @ViewBuilder
    private func timelineRow(time: String, text: String, showsDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.lg) {
                Text(time)
                    .font(.time)
                    .foregroundStyle(Color.textSecondary.opacity(0.6))
                    .frame(minWidth: 40, alignment: .leading)

                Text(text)
                    .font(Font.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 14)

            if showsDivider {
                Rectangle()
                    .fill(Color.borderDefault)
                    .frame(height: 1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("At \(time), \(text)")
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        Spacer().frame(height: Spacing.xxxl)
        Text("See you tomorrow")
            .font(Font.system(size: 13, weight: .regular))
            .foregroundStyle(Color.textSecondary.opacity(0.6))
    }
}

private struct WeeklyBarCell: View {
    let count: Int
    let label: String
    let isToday: Bool
    let fraction: Double
    let isSelected: Bool
    let reduceMotion: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            ChartBar(
                count: count,
                label: label,
                isToday: isToday,
                fraction: fraction
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.textPrimary.opacity(0.25) : .clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .animation(
                reduceMotion ? nil : Motion.entranceCurve,
                value: count
            )

            Circle()
                .fill(isSelected ? Color.textPrimary : .clear)
                .frame(width: 4, height: 4)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label), \(count) \(count == 1 ? "item" : "items")")
    }
}

// MARK: - Previews

#Preview("Empty") {
    let container: ModelContainer = {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: DoneItem.self, configurations: cfg)
    }()
    return ReflectView()
        .modelContainer(container)
        .environment(DoneStore(context: container.mainContext))
}

#Preview("Populated") {
    let container: ModelContainer = {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let c = try! ModelContainer(for: DoneItem.self, configurations: cfg)
        let ctx = c.mainContext
        let today = DoneStore.todayKey()
        let cal = Calendar.current
        let now = Date.now

        // Today's items, spread across the day.
        for (text, hoursAgo) in [
            ("Replied to overdue emails", 7),
            ("Finished the budget spreadsheet", 4),
            ("Took a 10-min walk", 1),
        ] {
            let when = now.addingTimeInterval(-Double(hoursAgo * 3600))
            ctx.insert(DoneItem(
                text: text,
                time: DoneStore.timeKey(now: when),
                date: today,
                createdAt: when
            ))
        }

        // Earlier days with varying counts so the weekly chart has shape.
        let pattern = [2, 5, 1, 4, 0, 3]   // 6…1 days ago
        for (offsetMinusOne, count) in pattern.enumerated() {
            let dayOffset = pattern.count - offsetMinusOne     // 6 … 1
            guard let date = cal.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            let key = DoneStore.todayKey(now: date)
            for i in 0..<count {
                ctx.insert(DoneItem(
                    text: "Sample \(i + 1)",
                    time: "10:00",
                    date: key,
                    createdAt: date
                ))
            }
        }
        return c
    }()

    return ReflectView()
        .modelContainer(container)
        .environment(DoneStore(context: container.mainContext))
}
