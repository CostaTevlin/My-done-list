// DoneItem.swift
// SwiftData model representing one logged done-thing.
//
// Phase: 2
// R4: added EntrySource (additive column — no migration plan needed; existing rows get .text default).
// See: engineering/Architecture.md  ·  decisions/0003 — SwiftData persistence  ·  ADR-0010

import Foundation
import SwiftData

/// How the entry was captured. Stored as a raw String so SwiftData persists it
/// without a Codable transformer. Existing rows that pre-date R4 get `.text` via
/// the property-level default.
enum EntrySource: String, Codable {
    case voice
    case text
}

@Model
final class DoneItem {
    var text: String
    var time: String         // formatted "HH:mm" for display parity with PWA
    var date: String         // yyyy-MM-dd local — matches PWA `todayKey`
    var createdAt: Date
    // Stored as a raw String so SwiftData can migrate existing rows to the "text"
    // default without an enum-cast failure (Optional<Any> → EntrySource crashes).
    var sourceRaw: String = "text"   // additive R4 column

    /// Typed accessor — not persisted; backed by `sourceRaw`.
    var source: EntrySource {
        get { EntrySource(rawValue: sourceRaw) ?? .text }
        set { sourceRaw = newValue.rawValue }
    }

    init(
        text: String,
        time: String,
        date: String,
        createdAt: Date = .now,
        source: EntrySource = .text
    ) {
        self.text = text
        self.time = time
        self.date = date
        self.createdAt = createdAt
        self.sourceRaw = source.rawValue
    }
}
