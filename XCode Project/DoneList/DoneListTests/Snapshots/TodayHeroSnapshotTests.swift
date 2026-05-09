// TodayHeroSnapshotTests.swift
// Visual capture tests for HeroBlock at key count values (0, 1, 3, 7).
// Uses ImageRenderer to render the component at iPhone 15 Pro width (@3x) and
// attaches the result for visual inspection in Xcode's test results pane.
//
// Phase: 5 (ADR-0011 — ADHD-first repositioning)
// Note: These are visual-capture tests. Pixel-comparison regression tests require
//       adding the SnapshotTesting SPM package (decision per testing.md §Snapshot).

import XCTest
import SwiftUI
@testable import DoneList
import DesignSystem

@MainActor
final class TodayHeroSnapshotTests: XCTestCase {

    // iPhone 15 Pro logical width. Fixed height covers numeral + label + insight at
    // default Dynamic Type. Padding matches TodayView's header insets (Spacing.xxl = 28pt).
    private let canvasWidth: CGFloat = 393
    private let canvasHeight: CGFloat = 320
    private let testHour: Int = 10    // mid-morning — stable seed for all snapshots

    private func renderHeroBlock(count: Int) -> UIImage? {
        let insight = CopyBank.todayHeroInsight(count: count, hour: testHour)
        let label = CopyBank.todayHeroSupportingLabel(count: count)
        let view = HeroBlock(count: count, supportingLabel: label, insight: insight)
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .background(Color.tokenWhite)
            .frame(width: canvasWidth, height: canvasHeight, alignment: .topLeading)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3  // @3x matches iPhone 15 Pro
        return renderer.uiImage
    }

    private func attach(image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testSnapshot_count0() throws {
        let image = try XCTUnwrap(renderHeroBlock(count: 0), "ImageRenderer returned nil for count 0")
        attach(image: image, name: "HeroBlock_count0")
        XCTAssertGreaterThan(image.size.width, 0)
        XCTAssertGreaterThan(image.size.height, 0)
    }

    func testSnapshot_count1() throws {
        let image = try XCTUnwrap(renderHeroBlock(count: 1), "ImageRenderer returned nil for count 1")
        attach(image: image, name: "HeroBlock_count1_singular")
        XCTAssertGreaterThan(image.size.width, 0)
        XCTAssertGreaterThan(image.size.height, 0)
    }

    func testSnapshot_count3() throws {
        let image = try XCTUnwrap(renderHeroBlock(count: 3), "ImageRenderer returned nil for count 3")
        attach(image: image, name: "HeroBlock_count3")
        XCTAssertGreaterThan(image.size.width, 0)
        XCTAssertGreaterThan(image.size.height, 0)
    }

    func testSnapshot_count7() throws {
        let image = try XCTUnwrap(renderHeroBlock(count: 7), "ImageRenderer returned nil for count 7")
        attach(image: image, name: "HeroBlock_count7_longestInsight")
        XCTAssertGreaterThan(image.size.width, 0)
        XCTAssertGreaterThan(image.size.height, 0)
    }
}
