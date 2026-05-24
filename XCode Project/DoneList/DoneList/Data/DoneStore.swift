// DoneStore.swift
// @Observable façade over the SwiftData ModelContext.
// Owns: CRUD · prune · todayKey · week aggregation · confetti fire counter.
//
// Phase: 2
// See: engineering/Architecture.md  ·  engineering/Testing strategy.md

import Foundation
import SwiftData
import Observation

@Observable
final class DoneStore {

    // MARK: - Shared container

    /// App-wide SwiftData container. Phase 2 uses local-only persistence; Phase 9
    /// flips this to `cloudKitDatabase: .private` (see ADR-0009).
    @MainActor
    static let container: ModelContainer = {
        let schema = Schema([DoneItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("DoneStore: failed to create ModelContainer — \(error)")
        }
    }()

    // MARK: - Observable state

    /// Bumped on every successful log so `ConfettiOverlay` can react via `.task(id:)`.
    private(set) var confettiFireCount: Int = 0

    /// Cached `todayKey()` so views can react to midnight rollover without
    /// recomputing per render.
    private(set) var todayKeyValue: String

    // MARK: - Storage

    private let context: ModelContext

    /// Production initializer using the shared container.
    /// `@MainActor` so it can touch `container.mainContext` safely.
    @MainActor
    convenience init() {
        self.init(context: DoneStore.container.mainContext)
    }

    /// Test initializer accepting any context (typically an in-memory one).
    /// Plain `init` — no actor isolation — so tests can run without MainActor pinning.
    init(context: ModelContext) {
        self.context = context
        self.todayKeyValue = Self.todayKey()
    }

    // MARK: - Date helpers (pure, static, side-effect free)

    /// Stable `yyyy-MM-dd` formatter using POSIX locale so the string format
    /// is independent of the user's regional settings, but in the user's
    /// local time zone so the day boundary matches their experience.
    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "HH:mm"
        return f
    }()

    static func todayKey(now: Date = .now) -> String {
        return dayFormatter.string(from: now)
    }

    static func timeKey(now: Date = .now) -> String {
        return timeFormatter.string(from: now)
    }

    static func padded(_ n: Int) -> String {
        return n < 10 ? "0\(n)" : "\(n)"
    }

    /// Returns the last 7 day-keys in ascending order, ending with today.
    /// Used by Reflect's weekly chart aggregation.
    static func weekRange(now: Date = .now) -> [String] {
        let cal = Calendar.current
        return (0..<7).reversed().compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: -offset, to: now) else {
                return nil
            }
            return todayKey(now: date)
        }
    }

    /// One day in the Reflect weekly chart — mirrors the PWA's `{key, label, count}`
    /// trio plus an `isToday` flag for the highlight state.
    struct WeekDay: Equatable, Identifiable {
        let key: String
        let label: String
        let count: Int
        let isToday: Bool
        var id: String { key }
    }

    /// Aggregates the supplied items into 7 ordered buckets ending with today.
    /// Pure / static so the view layer can call it from a `@Query` result and
    /// the unit tests can verify it without spinning up a ModelContext.
    /// Mirrors PWA `weekData` (index.html line 568-579) but uses local-time
    /// day keys to stay consistent with `todayKey()`.
    static func weekData(items: [DoneItem], now: Date = .now) -> [WeekDay] {
        let cal = Calendar.current
        let today = todayKey(now: now)
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        // Bucket once — O(n) instead of N filter passes.
        var counts: [String: Int] = [:]
        for item in items {
            counts[item.date, default: 0] += 1
        }

        return (0..<7).reversed().compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: -offset, to: now) else {
                return nil
            }
            let key = todayKey(now: date)
            let weekdayIndex = cal.component(.weekday, from: date) - 1   // 0…Sun
            let label = (offset == 0) ? "Today" : dayNames[weekdayIndex]
            return WeekDay(
                key: key,
                label: label,
                count: counts[key] ?? 0,
                isToday: key == today
            )
        }
    }

    func recomputeTodayKey() {
        todayKeyValue = Self.todayKey()
    }

    // MARK: - CRUD

    /// Add a new done item with the current time + todayKey. Mirrors the PWA's
    /// 2-character minimum gate (`index.html` line ~440).
    /// `source` defaults to `.text`; pass `.voice` for voice-captured entries (R4, ADR-0010).
    func add(text: String, source: EntrySource = .text) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return }

        let now = Date.now
        let item = DoneItem(
            text: trimmed,
            time: Self.timeKey(now: now),
            date: Self.todayKey(now: now),
            createdAt: now,
            source: source
        )
        context.insert(item)
        try? context.save()
    }

    func delete(_ item: DoneItem) {
        context.delete(item)
        try? context.save()
    }

    func update(_ item: DoneItem, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return }
        item.text = trimmed
        try? context.save()
    }

    // MARK: - Maintenance

    /// Removes items older than `days` days, comparing against `createdAt`.
    /// Default 30 days — enough to power Reflect's 7-day chart with headroom.
    func pruneOlderThan(days: Int = 30) {
        guard let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: .now) else {
            return
        }
        let predicate = #Predicate<DoneItem> { item in
            item.createdAt < cutoff
        }
        let descriptor = FetchDescriptor<DoneItem>(predicate: predicate)
        guard let stale = try? context.fetch(descriptor) else { return }
        for item in stale {
            context.delete(item)
        }
        try? context.save()
    }

    /// Prune at most once per day to keep launch fast. Tracked via UserDefaults.
    func pruneIfNeeded(days: Int = 30) {
        let key = "DoneStore.lastPruneDay"
        let today = Self.todayKey()
        let last = UserDefaults.standard.string(forKey: key)
        guard last != today else { return }
        pruneOlderThan(days: days)
        UserDefaults.standard.set(today, forKey: key)
    }

    // MARK: - Confetti

    /// Bumped by LogSheet after a successful submit. ConfettiOverlay observes
    /// this counter via `.task(id:)` and renders one variant per increment.
    func fireConfetti() {
        confettiFireCount &+= 1
    }
}
