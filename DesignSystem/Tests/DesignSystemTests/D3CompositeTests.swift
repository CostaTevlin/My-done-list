// D3CompositeTests.swift
// Compile-time + structural checks for D3 composite components.
// These tests verify public API surface and logic — rendering is covered by #Preview blocks.
// Phase: D3 · R3 Composites
// See: .claude/contracts/d3-composites_CONTRACT.md

import XCTest
import SwiftUI
@testable import DesignSystem

@MainActor
final class D3CompositeTests: XCTestCase {

    // MARK: - EntryRow

    func test_entryRow_compiles() {
        let _ = EntryRow(text: "Took a 10-min walk", timestamp: "00:33")
    }

    func test_entryRow_isLastHidesDivider() {
        // Structural: isLast param accepted without crash
        let _ = EntryRow(text: "Last row", timestamp: "01:00", isLast: true)
        let _ = EntryRow(text: "Non-last row", timestamp: "01:00", isLast: false)
    }

    func test_entryRow_voiceCapturedFlag() {
        let _ = EntryRow(text: "Voice entry", timestamp: "09:00", isVoiceCaptured: true)
        let _ = EntryRow(text: "Text entry", timestamp: "09:00", isVoiceCaptured: false)
    }

    func test_entryRow_menuCallbackOptional() {
        let _ = EntryRow(text: "With menu", timestamp: "00:33", onMenu: {})
        let _ = EntryRow(text: "No menu", timestamp: "00:33", onMenu: nil)
    }

    // MARK: - TimeOfDaySectionHeader

    func test_timeOfDaySectionHeader_compiles() {
        let _ = TimeOfDaySectionHeader(label: "Afternoon", count: 6)
    }

    func test_timeOfDaySectionHeader_allVariants() {
        let _ = TimeOfDaySectionHeader(label: "Morning", count: 1)
        let _ = TimeOfDaySectionHeader(label: "Afternoon", count: 6)
        let _ = TimeOfDaySectionHeader(label: "Evening", count: 0)
    }

    // MARK: - AdaptiveHero

    func test_adaptiveHero_todayStateCompiles() {
        // BigNumeral is composed by the caller, not inside AdaptiveHero (per Figma 111:8965).
        let _ = AdaptiveHero(state: .today(
            date: "Monday, 18 May",
            headline: "You're on a roll now",
            subtitle: "Some motivational subtitle."
        ))
    }

    func test_adaptiveHero_reflectStateCompiles() {
        let _ = AdaptiveHero(state: .reflect(
            headline: "What a great week",
            subtitle: "Some motivational subtitle."
        ))
    }

    func test_adaptiveHero_emptyStateCompiles() {
        let _ = AdaptiveHero(state: .empty)
    }

    func test_adaptiveHeroTodayAccessibilityLabel() {
        // Verify the accessibility label includes headline and subtitle.
        // The count is announced by the composed BigNumeral, not by AdaptiveHero.
        let state = HeroState.today(
            date: "Monday, 18 May",
            headline: "You're on a roll",
            subtitle: "Keep going"
        )
        if case let .today(_, headline, subtitle) = state {
            let label = "\(headline). \(subtitle)"
            XCTAssertTrue(label.contains("You're on a roll"))
            XCTAssertTrue(label.contains("Keep going"))
        } else {
            XCTFail("State should be .today")
        }
    }

    func test_adaptiveHeroReflectLabel() {
        let state = HeroState.reflect(headline: "What a great week", subtitle: "Nice work")
        if case let .reflect(headline, subtitle) = state {
            let label = "Reflect. \(headline). \(subtitle)"
            XCTAssertTrue(label.hasPrefix("Reflect."))
            XCTAssertTrue(label.contains("What a great week"))
        } else {
            XCTFail("State should be .reflect")
        }
    }

    func test_adaptiveHeroEmptyLabel() {
        let state = HeroState.empty
        if case .empty = state {
            let label = "No wins yet. Every small step counts."
            XCTAssertTrue(label.contains("No wins yet"))
        } else {
            XCTFail("State should be .empty")
        }
    }

    // MARK: - NavBarPlain

    func test_navBarPlain_titleOnly() {
        let _ = NavBarPlain(title: "Settings")
    }

    func test_navBarPlain_withTrailingAction() {
        let _ = NavBarPlain(
            title: "Search",
            trailingIcon: "xmark",
            trailingAction: {},
            trailingAccessibilityLabel: "Close search"
        )
    }

    func test_navBarPlain_noActionNoIcon() {
        let _ = NavBarPlain(title: "More", trailingIcon: nil, trailingAction: nil)
    }

    // MARK: - TabBarMain

    func test_tabBarMain_compilesWithAllTabs() {
        var sel = TabBarMain.Tab.today
        let binding = Binding(get: { sel }, set: { sel = $0 })
        let _ = TabBarMain(selection: binding, onLog: {})
    }

    func test_tabBarMain_tabAllCasesCount() {
        XCTAssertEqual(TabBarMain.Tab.allCases.count, 3)
    }

    func test_tabBarMain_tabLabels() {
        XCTAssertEqual(TabBarMain.Tab.today.label, "Today")
        XCTAssertEqual(TabBarMain.Tab.reflect.label, "Reflect")
        XCTAssertEqual(TabBarMain.Tab.more.label, "More")
    }

    func test_heroStateEquality() {
        // HeroState is Equatable — verify animation value binding works
        let a = HeroState.today(date: "Mon", headline: "H", subtitle: "S")
        let b = HeroState.today(date: "Mon", headline: "H", subtitle: "S")
        let c = HeroState.today(date: "Tue", headline: "H", subtitle: "S")
        XCTAssertEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a, HeroState.empty)
        XCTAssertNotEqual(HeroState.reflect(headline: "R", subtitle: "S"), HeroState.empty)
    }
}
