//
//  DoneListTests.swift
//  DoneListTests
//
//  Phase 2 tests: DoneStore CRUD + prune + todayKey + DateRollover.
//  Style: Apple's Swift Testing framework (the `Testing` module), per the
//  default Xcode-26 test scaffold.
//
//  See: engineering/Testing strategy.md
//

import Testing
import Foundation
import SwiftData
@testable import DoneList

// MARK: - Helpers

private func makeStore() throws -> (DoneStore, ModelContext) {
    let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
    let ctx = ModelContext(container)
    return (DoneStore(context: ctx), ctx)
}

// MARK: - DoneStore

@Suite(.serialized)
struct DoneStoreTests {

    // MARK: Date helpers

    @Test("todayKey returns yyyy-MM-dd format")
    func todayKey_format() {
        let key = DoneStore.todayKey()
        let regex = try? NSRegularExpression(pattern: #"^\d{4}-\d{2}-\d{2}$"#)
        let range = NSRange(location: 0, length: (key as NSString).length)
        let match = regex?.firstMatch(in: key, range: range)
        #expect(match != nil, "todayKey '\(key)' didn't match yyyy-MM-dd")
    }

    @Test("todayKey is stable for the same Date")
    func todayKey_isStable() {
        let now = Date.now
        #expect(DoneStore.todayKey(now: now) == DoneStore.todayKey(now: now))
    }

    @Test("padded zero-pads single digits")
    func padded() {
        #expect(DoneStore.padded(0) == "00")
        #expect(DoneStore.padded(7) == "07")
        #expect(DoneStore.padded(9) == "09")
        #expect(DoneStore.padded(10) == "10")
        #expect(DoneStore.padded(99) == "99")
    }

    @Test("weekRange returns 7 ascending day-keys ending today")
    func weekRange_returnsLast7Days() {
        let range = DoneStore.weekRange()
        #expect(range.count == 7)
        #expect(range.last == DoneStore.todayKey())
        // Ascending: each next entry should be lexicographically >= previous
        // (works because yyyy-MM-dd is sortable as a string).
        for i in 1..<range.count {
            #expect(range[i - 1] <= range[i])
        }
    }

    // MARK: weekData

    @Test("weekData returns 7 ordered buckets ending with today")
    func weekData_shape() throws {
        let week = DoneStore.weekData(items: [])
        #expect(week.count == 7)
        #expect(week.last?.key == DoneStore.todayKey())
        #expect(week.last?.label == "Today")
        #expect(week.last?.isToday == true)
        for i in 1..<week.count {
            #expect(week[i - 1].key <= week[i].key)
        }
        // Only the last bucket is flagged today.
        for i in 0..<(week.count - 1) {
            #expect(week[i].isToday == false)
        }
    }

    @Test("weekData empty input gives all zero counts")
    func weekData_emptyCounts() {
        let week = DoneStore.weekData(items: [])
        for day in week {
            #expect(day.count == 0)
        }
    }

    @Test("weekData buckets items into the correct days")
    func weekData_bucketing() throws {
        let cal = Calendar.current
        let now = Date.now
        let today = DoneStore.todayKey(now: now)

        guard
            let yesterday = cal.date(byAdding: .day, value: -1, to: now),
            let twoDaysAgo = cal.date(byAdding: .day, value: -2, to: now)
        else {
            Issue.record("calendar arithmetic failed")
            return
        }
        let yKey = DoneStore.todayKey(now: yesterday)
        let dKey = DoneStore.todayKey(now: twoDaysAgo)

        let items: [DoneItem] = [
            DoneItem(text: "a", time: "10:00", date: today, createdAt: now),
            DoneItem(text: "b", time: "11:00", date: today, createdAt: now),
            DoneItem(text: "c", time: "09:00", date: yKey, createdAt: yesterday),
            DoneItem(text: "d", time: "08:00", date: dKey, createdAt: twoDaysAgo),
            DoneItem(text: "e", time: "07:00", date: dKey, createdAt: twoDaysAgo),
            DoneItem(text: "f", time: "06:00", date: dKey, createdAt: twoDaysAgo),
        ]

        let week = DoneStore.weekData(items: items, now: now)
        let map = Dictionary(uniqueKeysWithValues: week.map { ($0.key, $0.count) })
        #expect(map[today] == 2)
        #expect(map[yKey] == 1)
        #expect(map[dKey] == 3)
    }

    @Test("weekData ignores items outside the 7-day window")
    func weekData_ignoresStaleItems() throws {
        let cal = Calendar.current
        let now = Date.now
        guard let tenDaysAgo = cal.date(byAdding: .day, value: -10, to: now) else {
            Issue.record("calendar arithmetic failed")
            return
        }
        let staleKey = DoneStore.todayKey(now: tenDaysAgo)
        let items: [DoneItem] = [
            DoneItem(text: "old", time: "10:00", date: staleKey, createdAt: tenDaysAgo)
        ]
        let week = DoneStore.weekData(items: items, now: now)
        for day in week {
            #expect(day.count == 0)
            #expect(day.key != staleKey)
        }
    }

    @Test("weekData earlier days use short weekday labels (not 'Today')")
    func weekData_labels() {
        let week = DoneStore.weekData(items: [])
        let validLabels: Set<String> = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        for day in week.dropLast() {
            #expect(validLabels.contains(day.label))
        }
    }

    // MARK: CRUD

    @Test("add inserts item with current time and todayKey")
    func add_insertsItem() throws {
        let (store, ctx) = try makeStore()
        store.add(text: "Wrote tests")

        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.count == 1)
        #expect(all.first?.text == "Wrote tests")
        #expect(all.first?.date == DoneStore.todayKey())
    }

    @Test("add ignores text shorter than 2 chars")
    func add_ignoresShortText() throws {
        let (store, ctx) = try makeStore()
        store.add(text: "")
        store.add(text: " ")
        store.add(text: "a")
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.isEmpty)
    }

    @Test("add trims surrounding whitespace before storing")
    func add_trimsWhitespace() throws {
        let (store, ctx) = try makeStore()
        store.add(text: "  hello  \n")
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.first?.text == "hello")
    }

    @Test("add stores the provided source (R4 EntrySource)")
    func add_storesSource() throws {
        let (store, ctx) = try makeStore()
        store.add(text: "Said something out loud", source: .voice)
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.first?.source == .voice)
    }

    @Test("add without source defaults to .text (backward-compat)")
    func add_defaultsToText() throws {
        let (store, ctx) = try makeStore()
        store.add(text: "Wrote tests")
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.first?.source == .text)
    }

    @Test("add with voice source still rejects text shorter than 2 chars")
    func add_shortTextRejectedRegardlessOfSource() throws {
        let (store, ctx) = try makeStore()
        store.add(text: "a", source: .voice)
        store.add(text: "",  source: .voice)
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.isEmpty)
    }

    @Test("update persists trimmed text on an existing item")
    func update_persistsTrimmedText() throws {
        let (store, ctx) = try makeStore()
        let item = DoneItem(text: "original", time: "10:00", date: DoneStore.todayKey())
        ctx.insert(item)
        try ctx.save()

        store.update(item, text: "  revised  ")
        #expect(item.text == "revised")
    }

    @Test("update rejects text shorter than 2 chars")
    func update_ignoresShortText() throws {
        let (store, ctx) = try makeStore()
        let item = DoneItem(text: "original", time: "10:00", date: DoneStore.todayKey())
        ctx.insert(item)
        try ctx.save()

        store.update(item, text: "x")
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.first?.text == "original")
    }

    @Test("update preserves source field")
    func update_preservesSource() throws {
        let (store, ctx) = try makeStore()
        let item = DoneItem(text: "voice entry", time: "10:00", date: DoneStore.todayKey(), source: .voice)
        ctx.insert(item)
        try ctx.save()

        store.update(item, text: "edited text")
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.first?.source == .voice)
    }

    @Test("delete removes the item")
    func delete_removesItem() throws {
        let (store, ctx) = try makeStore()
        let item = DoneItem(text: "to delete", time: "10:00", date: DoneStore.todayKey())
        ctx.insert(item)
        try ctx.save()

        store.delete(item)
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.isEmpty)
    }

    // MARK: Prune

    @Test("pruneOlderThan removes items older than the cutoff")
    func prune_removesOldItems() throws {
        let (store, ctx) = try makeStore()
        let day: TimeInterval = 60 * 60 * 24
        let old = DoneItem(
            text: "old", time: "10:00", date: "2026-01-01",
            createdAt: Date.now.addingTimeInterval(-31 * day)
        )
        let recent = DoneItem(
            text: "recent", time: "10:00", date: DoneStore.todayKey(),
            createdAt: Date.now
        )
        ctx.insert(old)
        ctx.insert(recent)
        try ctx.save()

        store.pruneOlderThan(days: 30)

        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.count == 1)
        #expect(all.first?.text == "recent")
    }

    @Test("pruneOlderThan keeps items exactly at the cutoff (boundary)")
    func prune_keepsBoundaryItems() throws {
        let (store, ctx) = try makeStore()
        let day: TimeInterval = 60 * 60 * 24
        // 29 days ago — should be kept under a 30-day prune.
        let nearCutoff = DoneItem(
            text: "boundary", time: "10:00", date: "2026-04-01",
            createdAt: Date.now.addingTimeInterval(-29 * day)
        )
        ctx.insert(nearCutoff)
        try ctx.save()

        store.pruneOlderThan(days: 30)

        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.count == 1)
    }

    // MARK: Confetti

    @Test("fireConfetti increments the counter")
    func fireConfetti_increments() throws {
        let (store, _) = try makeStore()
        let initial = store.confettiFireCount
        store.fireConfetti()
        #expect(store.confettiFireCount == initial + 1)
        store.fireConfetti()
        store.fireConfetti()
        #expect(store.confettiFireCount == initial + 3)
    }
}

// MARK: - DateRollover

@Suite(.serialized)
struct DateRolloverTests {

    @Test("next midnight after noon is 11-13 hours away")
    func nextMidnight_isAboutTwelveHoursAway() throws {
        let cal = Calendar.current
        let noon = try #require(
            cal.date(bySettingHour: 12, minute: 0, second: 0, of: Date.now)
        )
        let next = try #require(
            cal.nextDate(
                after: noon,
                matching: DateComponents(hour: 0, minute: 0, second: 0),
                matchingPolicy: .nextTime
            )
        )
        let diff = next.timeIntervalSince(noon)
        // DST swings can stretch this slightly; 11-13h covers all real cases.
        #expect(diff > 11 * 3600)
        #expect(diff < 13 * 3600)
    }

    @Test("schedule + cancel does not crash")
    func schedule_cancel_safe() async {
        let rollover = DateRollover(onRollover: {})
        rollover.schedule()
        rollover.cancel()
        rollover.schedule()
        rollover.cancel()
        // Pure smoke test — make sure the lifecycle is safe.
        #expect(true)
    }
}
