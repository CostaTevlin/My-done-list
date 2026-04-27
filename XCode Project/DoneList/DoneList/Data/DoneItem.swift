// DoneItem.swift
// SwiftData model representing one logged done-thing.
//
// Phase: 2
// See: engineering/Architecture.md  ·  decisions/0003 — SwiftData persistence

import Foundation
import SwiftData

@Model
final class DoneItem {
    var text: String
    var time: String         // formatted "HH:mm" for display parity with PWA
    var date: String         // yyyy-MM-dd local — matches PWA `todayKey`
    var createdAt: Date

    init(text: String, time: String, date: String, createdAt: Date = .now) {
        self.text = text
        self.time = time
        self.date = date
        self.createdAt = createdAt
    }
}
