// DateRollover.swift
// Schedules a Timer for the next midnight; recomputes todayKey on fire.
//
// Phase: 2
// See: engineering/Architecture.md (Lifecycle & scene phase)

import Foundation

final class DateRollover {
    private var timer: Timer?
    private let onRollover: () -> Void

    init(onRollover: @escaping () -> Void) {
        self.onRollover = onRollover
    }

    func schedule() {
        // Phase 2: Calendar.current.nextDate(after: .now, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTime)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}
