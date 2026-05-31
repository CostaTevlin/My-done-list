// InsightsEngine.swift
// Rolling-median threshold and other insight computations.
// Phase: 5 · See: Phase 5 hero contract §9

import Foundation
import SwiftData

enum InsightsEngine {

    /// Rolling 7-day median of completed-day counts, today excluded.
    /// Returns at least 1 — so first log of an empty-history user fills the ring.
    ///
    /// Days with zero logs are NOT included in the median. Only days the user
    /// actually used the app contribute — prevents threshold collapsing to 0
    /// for a user who skipped most of the last 7 days.
    static func rollingMedianThreshold(in context: ModelContext) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        guard let weekAgo = cal.date(byAdding: .day, value: -7, to: today) else { return 1 }

        let descriptor = FetchDescriptor<DoneItem>(
            predicate: #Predicate { $0.createdAt >= weekAgo && $0.createdAt < today }
        )
        let items = (try? context.fetch(descriptor)) ?? []

        let buckets = Dictionary(grouping: items) { cal.startOfDay(for: $0.createdAt) }
        let counts = buckets.values.map(\.count).sorted()

        guard !counts.isEmpty else { return 1 }
        let mid = counts.count / 2
        let median = counts.count.isMultiple(of: 2)
            ? (counts[mid - 1] + counts[mid]) / 2
            : counts[mid]
        return max(1, median)
    }
}
