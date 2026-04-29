// NotificationScheduler.swift
// Wraps `UNUserNotificationCenter` for the daily-reminder lifecycle.
// Owns: authorization request, scheduling a single repeating calendar trigger,
// and removing it on toggle-off / time change.
//
// Phase: 7
// See: engineering/Architecture.md (Notifications)
//      design-system/Copy bank.md (Notification copy)
//      decisions/0008 — 4.2 risk mitigation

import Foundation
import UserNotifications

enum NotificationScheduler {

    /// Stable identifier so re-scheduling replaces (not duplicates) the
    /// pending request.
    static let dailyReminderID = "daily-reminder"

    // MARK: - Authorization

    /// Asks the system for `[.alert, .sound, .badge]` once. Subsequent calls
    /// after a denial silently resolve `false`.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func currentAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Schedule

    /// Replace any pending daily reminder with a fresh one at the supplied
    /// hour:minute (24-hour). Repeats every day. Body copy mirrors the PWA's
    /// notification design — short, calm, never imperative.
    static func scheduleDailyReminder(at hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderID])

        let content = UNMutableNotificationContent()
        content.title = "What did you do today?"
        content.body = "Take a moment to log one thing."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: dailyReminderID,
            content: content,
            trigger: trigger
        )
        center.add(request) { _ in
            // Best effort — if the add fails (e.g. authorization revoked),
            // the next Settings flip will retry.
        }
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [dailyReminderID])
    }
}
