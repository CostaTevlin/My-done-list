// DoneStore.swift
// @Observable façade over the SwiftData ModelContext.
// Owns: prune, todayKey, week aggregation, confetti fire counter.
//
// Phase: 2
// See: engineering/Architecture.md  ·  engineering/Testing strategy.md

import Foundation
import SwiftData
import Observation

@Observable
final class DoneStore {
    private(set) var confettiFireCount: Int = 0
    var todayKeyValue: String = ""

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        self.todayKeyValue = todayKey()
    }

    // MARK: - Date helpers

    func todayKey(now: Date = .now) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = .current
        f.timeZone = .current
        return f.string(from: now)
    }

    func recomputeTodayKey() {
        todayKeyValue = todayKey()
    }

    func padded(_ n: Int) -> String {
        return n < 10 ? "0\(n)" : "\(n)"
    }

    // MARK: - CRUD (Phase 2 stubs)

    func add(text: String) {
        // Phase 2 implementation
    }

    func delete(_ item: DoneItem) {
        // Phase 2 implementation
    }

    // MARK: - Maintenance

    func pruneOlderThan(days: Int) {
        // Phase 2 implementation
    }

    func pruneIfNeeded() {
        // Phase 2: only prune once per day to keep launch fast
    }

    // MARK: - Confetti

    func fireConfetti() {
        confettiFireCount &+= 1
    }
}
