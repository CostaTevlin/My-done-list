// DesignSystemTests.swift
// Phase 1: smoke tests that the package compiles and exposes the expected API.
// Phase 5: updated to use sage palette tokens (tokenInk, tokenSlate, etc.)
// Real tests landed in Phase 9 (a11y + Dynamic Type) and per-component as needed.
// See: engineering/Testing strategy.md

import XCTest
import SwiftUI
@testable import DesignSystem

final class DesignSystemTests: XCTestCase {

    // MARK: - Tokens compile + resolve

    func test_colorTokens_areAccessible() {
        // Compile-time check: all 8 brand color tokens exist (Phase 5 sage palette).
        _ = Color.tokenInk
        _ = Color.tokenSlate
        _ = Color.tokenMist
        _ = Color.tokenSage50
        _ = Color.tokenSage300
        _ = Color.tokenSage600
        _ = Color.tokenSurface
        _ = Color.tokenDanger
    }

    func test_typographyTokens_areAccessible() {
        // All 11 type tokens from Tokens.md (Phase 5 SF Pro scale).
        _ = Font.display
        _ = Font.displaySub
        _ = Font.bigNumeral
        _ = Font.body
        _ = Font.bodySub
        _ = Font.motivational
        _ = Font.num
        _ = Font.time
        _ = Font.label
        _ = Font.chartCount
        _ = Font.chartDayLabel
    }

    func test_kerningConstants_matchSpec() {
        // Phase 5: only .label kerning survives the SF Pro migration.
        XCTAssertEqual(TypographyKerning.label, 0.88)
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
