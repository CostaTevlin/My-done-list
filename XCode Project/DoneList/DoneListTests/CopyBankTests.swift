// CopyBankTests.swift
// Phase 3 — verifies greeting boundaries, message tier coverage, seed stability,
// and the empty-string contract for `count == 0`.
//
// See: design-system/Copy bank.md  ·  index.html lines 336-423

import Testing
import Foundation
@testable import DoneList

@Suite(.serialized)
struct CopyBankTests {

    // MARK: - Greeting

    @Test("greeting buckets hours into morning / afternoon / evening")
    func greeting_buckets() {
        #expect(CopyBank.greeting(hour: 0)  == "Good morning")
        #expect(CopyBank.greeting(hour: 5)  == "Good morning")
        #expect(CopyBank.greeting(hour: 11) == "Good morning")
        #expect(CopyBank.greeting(hour: 12) == "Good afternoon")
        #expect(CopyBank.greeting(hour: 16) == "Good afternoon")
        #expect(CopyBank.greeting(hour: 17) == "Good evening")
        #expect(CopyBank.greeting(hour: 23) == "Good evening")
    }

    // MARK: - Message — empty contract

    @Test("message returns empty for count == 0 regardless of hour")
    func message_emptyForZeroCount() {
        for h in 0..<24 {
            #expect(CopyBank.message(count: 0, hour: h).isEmpty)
        }
    }

    // MARK: - Message — non-empty for all positive counts

    @Test("message is non-empty for every (count, hour) pair where count > 0")
    func message_nonEmptyForPositiveCount() {
        for count in 1...20 {
            for h in 0..<24 {
                #expect(!CopyBank.message(count: count, hour: h).isEmpty,
                        "empty message for count=\(count) hour=\(h)")
            }
        }
    }

    // MARK: - Tier coverage

    @Test("count == 1 picks from the count-1 pool")
    func message_tierOne() {
        let m = CopyBank.message(count: 1, hour: 8)
        let pool = [
            "First win of the day. Let's go.",
            "And so it begins.",
            "The hardest one is behind you.",
            "That's the spark. Keep going.",
            "One down. You're officially unstoppable."
        ]
        #expect(pool.contains(m))
    }

    @Test("count == 2 picks from the count-2 pool")
    func message_tierTwo() {
        let m = CopyBank.message(count: 2, hour: 8)
        let pool = [
            "Two for two. You're warming up.",
            "A pattern is forming.",
            "Twice as productive as zero. Math checks out.",
            "Double trouble (the good kind).",
            "You didn't stop at one. Respect."
        ]
        #expect(pool.contains(m))
    }

    @Test("counts 3 and 4 share a pool")
    func message_tierThreeFour() {
        let pool = [
            "You're on a roll now.",
            "Small wins stack up fast.",
            "Your future self is already thanking you.",
            "Look at you go.",
            "This is what showing up looks like."
        ]
        for count in 3...4 {
            for h in 0..<24 {
                #expect(pool.contains(CopyBank.message(count: count, hour: h)))
            }
        }
    }

    @Test("counts 5-7 share a pool")
    func message_tierFiveSeven() {
        let pool = [
            "Okay, you're actually crushing it.",
            "Today is listening to you.",
            "You turned \"meh\" into momentum.",
            "Not bad? No — this is great.",
            "High five. Seriously."
        ]
        for count in 5...7 {
            for h in 0..<24 {
                #expect(pool.contains(CopyBank.message(count: count, hour: h)))
            }
        }
    }

    @Test("count >= 8 picks from the legend pool")
    func message_tierEightPlus() {
        let pool = [
            "Legend status: unlocked.",
            "Your done list has a done list.",
            "Peak productivity. Screenshot this.",
            "You showed up and didn't stop.",
            "Tomorrow's gonna be jealous of today."
        ]
        for count in [8, 9, 25, 99] {
            for h in 0..<24 {
                #expect(pool.contains(CopyBank.message(count: count, hour: h)))
            }
        }
    }

    // MARK: - Seed stability

    @Test("message is deterministic for the same (count, hour)")
    func message_isStable() {
        for count in 1...10 {
            for h in 0..<24 {
                let a = CopyBank.message(count: count, hour: h)
                let b = CopyBank.message(count: count, hour: h)
                #expect(a == b)
            }
        }
    }

    // MARK: - Seed formula parity with PWA

    @Test("seed formula matches PWA `(count * 7 + hour) % 5`")
    func message_seedFormulaParity() {
        // PWA: const seed = (count * 7 + h) % 5
        //
        // count=1, h=0 → seed = (7+0) % 5 = 2 → pool[2] for count-1
        #expect(CopyBank.message(count: 1, hour: 0) == "The hardest one is behind you.")

        // count=2, h=4 → seed = (14+4) % 5 = 3 → pool[3] for count-2
        #expect(CopyBank.message(count: 2, hour: 4) == "Double trouble (the good kind).")

        // count=3, h=10 → seed = (21+10) % 5 = 1 → pool[1] for count 3-4
        #expect(CopyBank.message(count: 3, hour: 10) == "Small wins stack up fast.")

        // count=8, h=0 → seed = (56+0) % 5 = 1 → pool[1] for count 8+
        #expect(CopyBank.message(count: 8, hour: 0) == "Your done list has a done list.")
    }
}
