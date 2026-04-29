// DateRollover.swift
// Schedules a Timer that fires at the next local midnight and re-arms itself.
// Combined with the scenePhase `.active` rollover in `DoneListApp`, this catches
// both phone-asleep day-changes and long-running foreground sessions.
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

    /// Schedule the next midnight fire. Safe to call repeatedly — cancels any
    /// existing timer first.
    func schedule(now: Date = .now) {
        cancel()

        let cal = Calendar.current
        guard let nextMidnight = cal.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) else {
            return
        }

        let interval = nextMidnight.timeIntervalSince(now)
        guard interval > 0 else { return }

        let t = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            self?.fire()
        }
        RunLoop.main.add(t, forMode: .common)
        self.timer = t
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }

    private func fire() {
        onRollover()
        schedule()  // re-arm for the following midnight
    }
}
