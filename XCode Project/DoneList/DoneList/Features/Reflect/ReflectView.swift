// ReflectView.swift
// Weekly bar chart + today's timeline + reflection note.
//
// Layout (top to bottom): label · "Your day so far" display · reflectNote ·
// "This week" weekly chart (horizontal scroll, 7 days, today highlighted) ·
// rule · chronological timeline (earliest first, time + text rows) ·
// "X things done today" · "See you tomorrow".
//
// Phase: 5
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

    // MARK: - Derived state

    /// Today's items ordered earliest → latest, matching the PWA's "timeline".
    private var timeline: [DoneItem] {
        allItems
            .filter { $0.date == store.todayKeyValue }
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
                header
                note
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
        .background(Color.tokenWhite.ignoresSafeArea())
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Reflect")
                .font(.tokenLabel)
                .kerning(TypographyKerning.label)
                .textCase(.uppercase)
                .foregroundStyle(Color.tokenLight)

            Spacer().frame(height: Spacing.lg)

            // PWA splits the title onto two lines deliberately ("Your day\nso far").
            // Negative lineSpacing collapses the leading toward
            // `TypographyLineHeight.display` (0.9×) so the two-line title
            // reads tight, matching the PWA.
            Text("Your day\nso far")
                .font(.tokenDisplay)
                .kerning(TypographyKerning.display)
                .foregroundStyle(Color.tokenCharcoal)
                .multilineTextAlignment(.leading)
                .lineSpacing(-12)
        }
    }

    // MARK: - Reflect note

    @ViewBuilder
    private var note: some View {
        Spacer().frame(height: 32)
        Text(reflectNote)
            .font(.tokenBody)
            .kerning(TypographyKerning.body)
            .foregroundStyle(Color.tokenDark)
            .frame(maxWidth: 300, alignment: .leading)
            .accessibilityLabel(reflectNote)
    }

    // MARK: - Weekly chart

    @ViewBuilder
    private var weeklyChart: some View {
        Spacer().frame(height: 32)
        Text("This week")
            .font(.tokenLabel)
            .kerning(TypographyKerning.label)
            .textCase(.uppercase)
            .foregroundStyle(Color.tokenLight)

        Spacer().frame(height: Spacing.lg)

        let week = weekData
        let maxCount = max(week.map(\.count).max() ?? 0, 1)

        // 7 columns flex to fill the strip — mirrors the PWA's
        // `display:flex; flex: 1 0 44px` so "Today" never gets clipped.
        HStack(alignment: .bottom, spacing: Spacing.sm) {
            ForEach(week) { day in
                ChartBar(
                    count: day.count,
                    label: day.label,
                    isToday: day.isToday,
                    fraction: Double(day.count) / Double(maxCount)
                )
                .animation(
                    reduceMotion ? nil : Motion.entranceCurve,
                    value: day.count
                )
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
            .fill(Color.tokenBorder)
            .frame(height: 1)
    }

    // MARK: - Timeline (chronological)

    @ViewBuilder
    private var timelineSection: some View {
        if timeline.isEmpty {
            Spacer().frame(height: 48)
            Text("Nothing to reflect on yet. Go to Today and log your first win.")
                .font(.tokenBody)
                .kerning(TypographyKerning.body)
                .foregroundStyle(Color.tokenMid)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer().frame(height: 48)
        } else {
            Spacer().frame(height: 20)
            VStack(spacing: 0) {
                ForEach(Array(timeline.enumerated()), id: \.element.persistentModelID) { offset, item in
                    let isLast = offset == timeline.count - 1
                    timelineRow(time: item.time, text: item.text, showsDivider: !isLast)
                }
            }
            Spacer().frame(height: Spacing.xl)
            Text("\(todayCount) \(todayCount == 1 ? "thing" : "things") done today")
                .font(.outfit(13, .regular))
                .foregroundStyle(Color.tokenLight)
        }
    }

    @ViewBuilder
    private func timelineRow(time: String, text: String, showsDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: Spacing.lg) {
                Text(time)
                    .font(.tokenTime)
                    .foregroundStyle(Color.tokenLight)
                    .frame(minWidth: 40, alignment: .leading)

                Text(text)
                    .font(.outfit(15, .regular))
                    .foregroundStyle(Color.tokenCharcoal)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 14)

            if showsDivider {
                Rectangle()
                    .fill(Color.tokenBorderLight)
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
            .font(.outfit(13, .regular))
            .foregroundStyle(Color.tokenLight)
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
