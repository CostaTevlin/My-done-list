// CopyBank.swift
// Greetings + motivational copy + reflection notes. Verbatim port from PWA index.html.
// Stable per (count, hour) within a session.
//
// Phase: 3 (Today uses message), 5 (Reflect uses reflectNote)
// v2: ADHD momentum tier added 2026-05-09 per ADR-0011 (todayHeroInsight, todayHeroSupportingLabel).
// See: design-system/Copy bank.md  · index.html lines 336-423

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

    /// Mirrors PWA `getReflectNote()` (index.html line 390-423).
    /// Seed formula `(count * 3 + hour) % 4` — note this differs from `message`'s
    /// `* 7 % 5` so the two screens never feel synced.
    /// `count == 0` returns a unique "rest day" pool — never empty.
    static func reflectNote(count: Int, hour: Int) -> String {
        let pool = reflectPool(for: count)
        let seed = ((count * 3) + hour) % pool.count
        let index = seed >= 0 ? seed : seed + pool.count
        return pool[index]
    }

    private static func reflectPool(for count: Int) -> [String] {
        switch count {
        case 0:
            return [
                "Tomorrow is a fresh start.",
                "Rest is productive too.",
                "Some days are for recharging.",
                "A blank page is still a page."
            ]
        case 1:
            return [
                "You showed up. That's the whole game.",
                "One thing done is infinitely more than zero.",
                "That one thing? It mattered.",
                "You started. Most people didn't."
            ]
        case 2...3:
            return [
                "Solid day. Every task counted.",
                "Steady wins the race.",
                "You kept going. That's the superpower.",
                "Quality over quantity. Always."
            ]
        case 4...6:
            return [
                "What a day. Be proud of yourself.",
                "You made today count.",
                "This is what a good day looks like.",
                "Impressive. Full stop."
            ]
        default: // 7+
            return [
                "An extraordinary day. Feel that.",
                "You were on fire today.",
                "Today was your masterpiece.",
                "Take a bow. You earned it."
            ]
        }
    }

    // MARK: - Today hero insight (ADHD momentum tier — v2, per ADR-0011)

    /// Returns an ADHD-voice insight line for the Today hero block.
    /// Same `(count * 7 + hour) % poolSize` rotation as `message(_:hour:)`.
    /// Pool size is 4. Never returns an empty string.
    static func todayHeroInsight(count: Int, hour: Int) -> String {
        let pool = heroInsightPool(for: count)
        let seed = ((count * 7) + hour) % pool.count
        return pool[seed]
    }

    /// Returns `"win today"` for count == 1, `"wins today"` otherwise.
    static func todayHeroSupportingLabel(count: Int) -> String {
        count == 1 ? "win today" : "wins today"
    }

    private static func heroInsightPool(for count: Int) -> [String] {
        switch count {
        case 0:
            return [
                "Your day starts here.",
                "One small thing, whenever you're ready.",
                "Nothing to prove. Just notice.",
                "A blank list isn't a verdict."
            ]
        case 1:
            return [
                "That's the start. Momentum builds from here.",
                "Small actions count.",
                "One thing logged is one more than nothing.",
                "You moved. That's the whole point."
            ]
        case 2...3:
            return [
                "You're building momentum.",
                "Small progress still counts.",
                "Your day has shape.",
                "Two or three is more than zero. That math matters."
            ]
        case 4...6:
            return [
                "You kept moving today.",
                "This is what a day with momentum looks like.",
                "You're showing up for yourself.",
                "Steady is its own kind of strong."
            ]
        default: // 7+
            return [
                "Your brain may forget this. The list won't.",
                "That's a full day of forward motion.",
                "Look at the shape of your day.",
                "You did more than you'll remember tomorrow."
            ]
        }
    }
}
