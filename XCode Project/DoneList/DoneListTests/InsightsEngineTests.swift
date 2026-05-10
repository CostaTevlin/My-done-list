// InsightsEngineTests.swift
// Unit tests for InsightsEngine.rollingMedianThreshold.
// Phase: 5 · implements contract §11

import XCTest
import SwiftData
@testable import DoneList

final class InsightsEngineTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: DoneItem.self, configurations: config)
        context = container.mainContext
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // Empty store → threshold 1 (first log fills the ring)
    func testRollingMedian_emptyStore() {
        XCTAssertEqual(InsightsEngine.rollingMedianThreshold(in: context), 1)
    }

    // Single log yesterday → single bucket of 1 → median 1
    func testRollingMedian_singleLogYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        context.insert(DoneItem(text: "Done something", time: "10:00",
                                date: DoneStore.todayKey(now: yesterday), createdAt: yesterday))
        XCTAssertEqual(InsightsEngine.rollingMedianThreshold(in: context), 1)
    }

    // Odd count: buckets [2, 5, 3] → sorted [2, 3, 5] → median 3
    func testRollingMedian_oddCountDays() {
        let counts = [2, 5, 3]
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)

        for (i, count) in counts.enumerated() {
            let day = cal.date(byAdding: .day, value: -(i + 1), to: today)!
            let key = DoneStore.todayKey(now: day)
            for j in 0..<count {
                context.insert(DoneItem(text: "Item \(j)", time: "10:00",
                                        date: key, createdAt: day))
            }
        }
        XCTAssertEqual(InsightsEngine.rollingMedianThreshold(in: context), 3)
    }

    // Even count: buckets [4, 2] → sorted [2, 4] → median (2+4)/2 = 3
    func testRollingMedian_evenCountDays() {
        let counts = [4, 2]
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)

        for (i, count) in counts.enumerated() {
            let day = cal.date(byAdding: .day, value: -(i + 1), to: today)!
            let key = DoneStore.todayKey(now: day)
            for j in 0..<count {
                context.insert(DoneItem(text: "Item \(j)", time: "10:00",
                                        date: key, createdAt: day))
            }
        }
        XCTAssertEqual(InsightsEngine.rollingMedianThreshold(in: context), 3)
    }
}
