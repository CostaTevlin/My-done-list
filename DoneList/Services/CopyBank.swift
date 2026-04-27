// CopyBank.swift
// Greetings + motivational copy + reflection notes. Verbatim port from PWA index.html.
// Stable per (count, hour) within a session.
//
// Phase: 3 (Today uses message), Phase 5 (Reflect uses reflectNote)
// See: design-system/Copy bank.md

import Foundation

enum CopyBank {
    static func greeting(hour: Int) -> String {
        switch hour {
        case 5..<12: return "Good morning,"
        case 12..<17: return "Good afternoon,"
        case 17..<23: return "Good evening,"
        default: return "Up late?"
        }
    }

    static func message(count: Int, hour: Int) -> String {
        // Phase 3: deterministic per-(count,hour) selection from tiers in design-system/Copy bank.md
        return ""
    }

    static func reflectNote(hour: Int) -> String {
        // Phase 5
        return ""
    }
}
