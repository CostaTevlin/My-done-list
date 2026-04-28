// LogDoneIntent.swift
// AppIntent exposing "Log to my done list" to Siri / Shortcuts / Spotlight.
// Inserts directly into the shared `DoneStore.container` on the main actor
// so the new item shows up in `@Query` the next time the app foregrounds.
//
// Phase: 7
// See: decisions/0008 — 4.2 risk mitigation
//      appstore/Review notes draft.md

import AppIntents
import Foundation
import SwiftData

struct LogDoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Log to my done list"
    static var description = IntentDescription(
        "Add an item to today's done list."
    )

    /// Allows Siri to read the dialog response back to the user.
    static var openAppWhenRun: Bool = false

    @Parameter(title: "What did you do?")
    var text: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            throw $text.needsValueError(
                "What did you do? Type at least two characters."
            )
        }

        let context = DoneStore.container.mainContext
        let now = Date.now
        let item = DoneItem(
            text: trimmed,
            time: DoneStore.timeKey(now: now),
            date: DoneStore.todayKey(now: now),
            createdAt: now
        )
        context.insert(item)
        try context.save()

        return .result(dialog: "Logged: \(trimmed)")
    }
}

struct DoneListShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogDoneIntent(),
            phrases: [
                "Log a thing in \(.applicationName)",
                "Add to my \(.applicationName)",
                "\(.applicationName) log \(\.$text)"
            ],
            shortTitle: "Log to done list",
            systemImageName: "checkmark.circle.fill"
        )
    }
}
