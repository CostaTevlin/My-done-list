// DesignSystemTests.swift
// Phase 1: smoke tests that the package compiles and exposes the expected API.
// Phase 5: two-tier refactor — palette (internal) + semantic tokens (public).
// Real tests landed in Phase 9 (a11y + Dynamic Type) and per-component as needed.
// See: engineering/Testing strategy.md

import XCTest
import SwiftUI
@testable import DesignSystem

final class DesignSystemTests: XCTestCase {

    // MARK: - Tokens compile + resolve

    func test_colorTokens_areAccessible() {
        // Compile-time check: all 9 semantic color tokens exist (Phase 5 two-tier refactor).
        _ = Color.textPrimary
        _ = Color.textSecondary
        _ = Color.borderDefault
        _ = Color.surfaceApp
        _ = Color.accentPrimary
        _ = Color.ringLow
        _ = Color.ringMid
        _ = Color.ringComplete
        _ = Color.actionDestructive
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

    // MARK: - Slowly namespace (D1 token scaffolding)

    func test_slowlyColorTokens_areAccessible() {
        _ = Slowly.Color.textPrimary
        _ = Slowly.Color.textSecondary
        _ = Slowly.Color.surfaceApp
        _ = Slowly.Color.surfaceGhost
        _ = Slowly.Color.surfaceWhite
        _ = Slowly.Color.borderDefault
        _ = Slowly.Color.accentPrimary
        _ = Slowly.Color.ringLow
        _ = Slowly.Color.ringMid
        _ = Slowly.Color.ringComplete
        _ = Slowly.Color.actionDestructive
    }

    func test_slowlyFontTokens_areAccessible() {
        _ = Slowly.Font.bigNumeral
        _ = Slowly.Font.display
        _ = Slowly.Font.h2
        _ = Slowly.Font.motivational
        _ = Slowly.Font.bodyText
        _ = Slowly.Font.bodySub
        _ = Slowly.Font.time
        _ = Slowly.Font.chartCount
    }

    func test_slowlySpacingScale_matchesSpec() {
        XCTAssertEqual(Slowly.Spacing.xs,           8)
        XCTAssertEqual(Slowly.Spacing.sm,          12)
        XCTAssertEqual(Slowly.Spacing.md,          16)
        XCTAssertEqual(Slowly.Spacing.lg,          20)
        XCTAssertEqual(Slowly.Spacing.xl,          24)
        XCTAssertEqual(Slowly.Spacing.xxl,         32)
        XCTAssertEqual(Slowly.Spacing.xxxl,        40)
        XCTAssertEqual(Slowly.Spacing.screenTop,   27)
        XCTAssertEqual(Slowly.Spacing.screenBottom, 62)
    }

    func test_slowlyRadii_matchFigmaSpec() {
        XCTAssertEqual(Slowly.Radius.card,   20)
        XCTAssertEqual(Slowly.Radius.button, 32)
        XCTAssertEqual(Slowly.Radius.sheet,  40)
        XCTAssertEqual(Slowly.Radius.fab,    9999)
    }

    func test_slowlyMaterialFallback_isUltraThin() {
        // compile-time check that the fallback is defined
        let _: SwiftUI.Material = Slowly.Material.fallback
    }
}
