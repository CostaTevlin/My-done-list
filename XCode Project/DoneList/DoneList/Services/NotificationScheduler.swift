// NotificationScheduler.swift
// Wraps UNUserNotificationCenter for the daily-reminder lifecycle.
//
// Phase: 7
// See: engineering/Architecture.md (Notifications)

import Foundation
import UserNotifications

enum NotificationScheduler {
    static let dailyReminderID = "daily-reminder"

    static func requestAuthorizationIfNeeded() async -> Bool {
        // Phase 7
        return false
    }

    static func scheduleDailyReminder(at hour: Int, minute: Int) {
        // Phase 7
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
    }
}
