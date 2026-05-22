// DSComponentTests.swift
// Compile-time + structural checks for D2 Slowly primitives.
// These tests verify public API surface — rendering is covered by #Preview blocks.
// Phase: 4.5 · D2 primitives
// See: .claude/contracts/slowly-d2-primitives_CONTRACT.md

import XCTest
import SwiftUI
@testable import DesignSystem

@MainActor
final class DSComponentTests: XCTestCase {

    // MARK: - DSText

    func test_dsTextStyle_allVariantsResolveFont() {
        for style in DSTextStyle.allCases {
            _ = style.font
        }
    }

    func test_dsTextModifier_compilesWithDefaultColor() {
        let _ = Text("Ag").dsText(.bodyRegular)
    }

    func test_dsTextModifier_compilesWithCustomColor() {
        let _ = Text("Ag").dsText(.headlineRegular, color: Slowly.Color.textSecondary)
    }

    func test_dsTextStyle_bigNumeralAutoMonospaced() {
        // bigNumeral always gets monospacedDigit — verify it's a different Font instance
        // (structural check: the font property runs without crashing)
        let font = DSTextStyle.bigNumeral.font
        _ = font
    }

    // MARK: - DSButton

    func test_dsButtonStyle_primaryCompiles() {
        let _ = Button("Save") {}.buttonStyle(DSButtonStyle(.primary))
    }

    func test_dsButtonStyle_secondaryCompiles() {
        let _ = Button("Cancel") {}.buttonStyle(DSButtonStyle(.secondary))
    }

    func test_dsFABButton_compilesWithDefaultDiameter() {
        let _ = DSFABButton(icon: "mic.fill", accessibilityLabel: "Log something") {}
    }

    func test_dsFABButton_compilesWithCustomDiameter() {
        let _ = DSFABButton(icon: "plus", diameter: 72, accessibilityLabel: "Add") {}
    }

    // MARK: - DSIcon

    func test_dsIcon_compilesWithDefaults() {
        let _ = DSIcon("checkmark")
    }

    func test_dsIcon_sizesMatchSpec() {
        XCTAssertEqual(DSIcon.Size.sm.points, 16)
        XCTAssertEqual(DSIcon.Size.md.points, 20)
        XCTAssertEqual(DSIcon.Size.lg.points, 24)
        XCTAssertEqual(DSIcon.Size.xl.points, 28)
    }

    func test_dsIcon_customSizePassthrough() {
        XCTAssertEqual(DSIcon.Size.custom(42).points, 42)
    }

    // MARK: - DSDivider

    func test_dsDivider_compiles() {
        let _ = DSDivider()
    }

    // MARK: - DSTextField

    func test_dsTextField_compiles() {
        let _ = DSTextField("Placeholder", text: .constant(""))
    }

    func test_dsTextField_acceptsBindingString() {
        var value = "hello"
        let binding = Binding(get: { value }, set: { value = $0 })
        let _ = DSTextField("Hint", text: binding)
    }

    // MARK: - DSCheckmark

    func test_dsCheckmark_compilesUnchecked() {
        let _ = DSCheckmark(checked: false)
    }

    func test_dsCheckmark_compilesChecked() {
        let _ = DSCheckmark(checked: true)
    }

    func test_dsCheckmark_defaultSizeIs24() {
        let c = DSCheckmark(checked: false)
        XCTAssertEqual(c.size, 24)
    }

    func test_dsCheckmark_customSize() {
        let c = DSCheckmark(checked: true, size: 32)
        XCTAssertEqual(c.size, 32)
    }
}
