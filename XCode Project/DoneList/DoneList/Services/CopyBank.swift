// CopyBank.swift
// Greetings + motivational copy + reflection notes. Verbatim port from PWA index.html.
// Stable per (count, hour) within a session.
//
// Phase: 3 (Today uses message), Phase 5 (Reflect uses reflectNote)
// See: design-system/Copy bank.md  ·  index.html lines 336-423

import Foundation

enum CopyBank {

    // MARK: - Greeting

    /// Mirrors PWA `getGreeting()` (index.html line 338-343).
    /// `0..<12 → morning · 12..<17 → afternoon · 17..<24 → evening`
    static func greeting(hour: Int) -> String {
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }

    // MARK: - Today motivational message

    /// Selects a motivational line based on `(count, hour)` using the PWA's
    /// `seed = (count * 7 + hour) % 5` formula. Stable for the same input —
    /// the line only changes as the count or hour changes.
    /// `count == 0` returns an empty string (Today header skips the line).
    static func message(count: Int, hour: Int) -> String {
        guard count > 0 else { return "" }
        let pool = messagePool(for: count)
        let seed = ((count * 7) + hour) % pool.count
        let index = seed >= 0 ? seed : seed + pool.count
        return pool[index]
    }

    private static func messagePool(for count: Int) -> [String] {
        switch count {
        case 1:
            return [
                "First win of the day. Let's go.",
                "And so it begins.",
                "The hardest one is behind you.",
                "That's the spark. Keep going.",
                "One down. You're officially unstoppable."
            ]
        case 2:
            return [
                "Two for two. You're warming up.",
                "A pattern is forming.",
                "Twice as productive as zero. Math checks out.",
                "Double trouble (the good kind).",
                "You didn't stop at one. Respect."
            ]
        case 3...4:
            return [
                "You're on a roll now.",
                "Small wins stack up fast.",
                "Your future self is already thanking you.",
                "Look at you go.",
                "This is what showing up looks like."
            ]
        case 5...7:
            return [
                "Okay, you're actually crushing it.",
                "Today is listening to you.",
                "You turned \"meh\" into momentum.",
                "Not bad? No — this is great.",
                "High five. Seriously."
            ]
        default: // 8+
            return [
                "Legend status: unlocked.",
                "Your done list has a done list.",
                "Peak productivity. Screenshot this.",
                "You showed up and didn't stop.",
                "Tomorrow's gonna be jealous of today."
            ]
        }
    }

    // MARK: - Reflect note

    /// Phase 5 — see `getReflectNote()` (index.html line 390-423).
    static func reflectNote(count: Int, hour: Int) -> String {
        // Phase 5
        return ""
    }
}
