// LogDoneIntent.swift
// AppIntent that exposes "Log to my done list" to Siri / Shortcuts / Spotlight.
// Critical for App Store Review 4.2 mitigation.
//
// Phase: 7
// See: decisions/0008 — 4.2 risk mitigation  ·  appstore/Review notes draft.md

import AppIntents
import Foundation

struct LogDoneIntent: AppIntent {
    static var title: LocalizedStringResource = "Log to my done list"
    static var description = IntentDescription("Add an item to today's done list.")

    @Parameter(title: "What did you do?")
    var text: String

    func perform() async throws -> some IntentResult {
        // Phase 7: insert into shared App Group SwiftData store
        return .result()
    }
}
