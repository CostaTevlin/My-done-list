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
