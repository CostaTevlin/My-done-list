// CopyBankADHDPoolTests.swift
// Phase 5 — verifies the ADHD momentum pool functions added per ADR-0011.
// todayHeroInsight: non-empty for every count tier, rotation by hour, determinism.
// todayHeroSupportingLabel: singular / plural contract.
//
// See: design-system/Copy bank.md §v2 ADHD momentum tier · ADR-0011

import Testing
import Foundation
@testable import DoneList

@Suite(.serialized)
struct CopyBankADHDPoolTests {

    // MARK: - todayHeroInsight — non-empty for spec count tiers

    @Test("heroInsight is non-empty for every count in spec (0, 1, 2, 3, 4, 6, 7, 12)")
    func heroInsight_nonEmptyForSpecCounts() {
        for count in [0, 1, 2, 3, 4, 6, 7, 12] {
            for h in 0..<24 {
                #expect(!CopyBank.todayHeroInsight(count: count, hour: h).isEmpty,
                        "empty insight for count=\(count) hour=\(h)")
            }
        }
    }

    // MARK: - Rotation by hour

    @Test("heroInsight rotates by hour — pool has 4 entries so 24 hours yield 4 unique values")
    func heroInsight_rotatesByHour() {
        for count in [0, 1, 3, 5, 9] {
            let results = (0..<24).map { CopyBank.todayHeroInsight(count: count, hour: $0) }
            let unique = Set(results)
            #expect(unique.count > 1,
                    "heroInsight never rotated for count=\(count); always '\(results[0])'")
        }
    }

    // MARK: - Determinism

    @Test("heroInsight is deterministic for the same (count, hour)")
    func heroInsight_isDeterministic() {
        for count in 0...12 {
            for h in 0..<24 {
                let a = CopyBank.todayHeroInsight(count: count, hour: h)
                let b = CopyBank.todayHeroInsight(count: count, hour: h)
                #expect(a == b, "non-deterministic for count=\(count) hour=\(h)")
            }
        }
    }

    // MARK: - Tier coverage

    @Test("heroInsight count 0 picks from the zero-count ADHD pool")
    func heroInsight_tierZero() {
        let pool: Set<String> = [
            "Your day starts here.",
            "One small thing, whenever you're ready.",
            "Nothing to prove. Just notice.",
            "A blank list isn't a verdict."
        ]
        for h in 0..<24 {
            #expect(pool.contains(CopyBank.todayHeroInsight(count: 0, hour: h)))
        }
    }

    @Test("heroInsight count 1 picks from the count-1 ADHD pool")
    func heroInsight_tierOne() {
        let pool: Set<String> = [
            "That's the start. Momentum builds from here.",
            "Small actions count.",
            "One thing logged is one more than nothing.",
            "You moved. That's the whole point."
        ]
        for h in 0..<24 {
            #expect(pool.contains(CopyBank.todayHeroInsight(count: 1, hour: h)))
        }
    }

    @Test("heroInsight counts 2-3 share the ADHD momentum pool")
    func heroInsight_tierTwoThree() {
        let pool: Set<String> = [
            "You're building momentum.",
            "Small progress still counts.",
            "Your day has shape.",
            "Two or three is more than zero. That math matters."
        ]
        for count in 2...3 {
            for h in 0..<24 {
                #expect(pool.contains(CopyBank.todayHeroInsight(count: count, hour: h)),
                        "unexpected string for count=\(count) hour=\(h)")
            }
        }
    }

    @Test("heroInsight counts 4-6 share the ADHD momentum pool")
    func heroInsight_tierFourSix() {
        let pool: Set<String> = [
            "You kept moving today.",
            "This is what a day with momentum looks like.",
            "You're showing up for yourself.",
            "Steady is its own kind of strong."
        ]
        for count in 4...6 {
            for h in 0..<24 {
                #expect(pool.contains(CopyBank.todayHeroInsight(count: count, hour: h)),
                        "unexpected string for count=\(count) hour=\(h)")
            }
        }
    }

    @Test("heroInsight count 7+ picks from the ADHD high-count pool")
    func heroInsight_tierSevenPlus() {
        let pool: Set<String> = [
            "Your brain may forget this. The list won't.",
            "That's a full day of forward motion.",
            "Look at the shape of your day.",
            "You did more than you'll remember tomorrow."
        ]
        for count in [7, 8, 12, 25] {
            for h in 0..<24 {
                #expect(pool.contains(CopyBank.todayHeroInsight(count: count, hour: h)),
                        "unexpected string for count=\(count) hour=\(h)")
            }
        }
    }

    // MARK: - Seed formula parity

    @Test("heroInsight seed formula is (count * 7 + hour) % 4")
    func heroInsight_seedFormulaParity() {
        // count=0, h=0 → seed = 0 % 4 = 0 → pool[0]
        #expect(CopyBank.todayHeroInsight(count: 0, hour: 0) == "Your day starts here.")

        // count=1, h=0 → seed = 7 % 4 = 3 → pool[3]
        #expect(CopyBank.todayHeroInsight(count: 1, hour: 0) == "You moved. That's the whole point.")

        // count=2, h=2 → seed = (14+2) % 4 = 0 → pool[0] for count 2-3
        #expect(CopyBank.todayHeroInsight(count: 2, hour: 2) == "You're building momentum.")

        // count=7, h=0 → seed = 49 % 4 = 1 → pool[1] for count 7+
        #expect(CopyBank.todayHeroInsight(count: 7, hour: 0) == "That's a full day of forward motion.")
    }

    // MARK: - Supporting label

    @Test("supportingLabel returns singular 'win today' for count == 1")
    func supportingLabel_singular() {
        #expect(CopyBank.todayHeroSupportingLabel(count: 1) == "win today")
    }

    @Test("supportingLabel returns plural 'wins today' for count != 1")
    func supportingLabel_plural() {
        for count in [0, 2, 3, 7, 99] {
            #expect(CopyBank.todayHeroSupportingLabel(count: count) == "wins today",
                    "expected 'wins today' for count=\(count)")
        }
    }
}
