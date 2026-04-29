// DesignSystemTests.swift
// Phase 1: smoke tests that the package compiles and exposes the expected API.
// Real tests landed in Phase 9 (a11y + Dynamic Type) and per-component as needed.
// See: engineering/Testing strategy.md

import XCTest
import SwiftUI
@testable import DesignSystem

final class DesignSystemTests: XCTestCase {

    // MARK: - Tokens compile + resolve

    func test_colorTokens_areAccessible() {
        // Compile-time check: all 9 brand color tokens exist.
        _ = Color.tokenWhite
        _ = Color.tokenOffWhite
        _ = Color.tokenBorder
        _ = Color.tokenBorderLight
        _ = Color.tokenCharcoal
        _ = Color.tokenDark
        _ = Color.tokenMid
        _ = Color.tokenLight
        _ = Color.tokenDanger
    }

    func test_typographyTokens_areAccessible() {
        // All 11 type tokens from Tokens.md.
        _ = Font.tokenDisplay
        _ = Font.tokenDisplaySub
        _ = Font.tokenBigNumeral
        _ = Font.tokenBody
        _ = Font.tokenBodySub
        _ = Font.tokenMotivational
        _ = Font.tokenNum
        _ = Font.tokenTime
        _ = Font.tokenLabel
        _ = Font.tokenChartCount
        _ = Font.tokenChartDayLabel
    }

    func test_kerningConstants_matchSpec() {
        XCTAssertEqual(TypographyKerning.display, -2.2)
        XCTAssertEqual(TypographyKerning.bigNumeral, -6.0)
        XCTAssertEqual(TypographyKerning.label, 0.88)
    }

    func test_lineHeightConstants_matchSpec() {
        XCTAssertEqual(TypographyLineHeight.bigNumeral, 0.82)
        XCTAssertEqual(TypographyLineHeight.body, 1.45)
    }

    // MARK: - Spacing scale

    func test_spacingScale_matchesSpec() {
        XCTAssertEqual(Spacing.xs, 4)
        XCTAssertEqual(Spacing.sm, 8)
        XCTAssertEqual(Spacing.md, 12)
        XCTAssertEqual(Spacing.lg, 16)
        XCTAssertEqual(Spacing.xl, 24)
        XCTAssertEqual(Spacing.xxl, 28)
        XCTAssertEqual(Spacing.xxxl, 40)
        XCTAssertEqual(Spacing.bottomSafe, 100)
    }

    // MARK: - Radius scale

    func test_radiusScale_matchesSpec() {
        XCTAssertEqual(Radius.card, 14)
        XCTAssertEqual(Radius.chip, 8)
    }

    // MARK: - Motion

    func test_motionStaggerInterval_is50ms() {
        XCTAssertEqual(Motion.entranceStagger, 0.05)
    }

    func test_motionConfettiCleanupBuffer_is200ms() {
        XCTAssertEqual(Motion.confettiCleanupBuffer, 0.2)
    }

    func test_motionSwipeThreshold_is80pt() {
        XCTAssertEqual(Motion.swipeThreshold, 80)
    }
}
