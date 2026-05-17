// TodayHeroSnapshotTests.swift (formerly HeroBlock tests — migrated to Hero in Phase 5)
// Visual capture tests for the Hero component at key count values.
// Phase: 5

import XCTest
import SwiftUI
@testable import DoneList
import DesignSystem

@MainActor
final class HeroSnapshotTests: XCTestCase {

    private let canvasWidth: CGFloat = 393
    private let canvasHeight: CGFloat = 380
    private let testHour: Int = 10

    private func renderTodayHero(count: Int, threshold: Int) -> UIImage? {
        let view = Hero(
            variant: .today(count: count, threshold: threshold),
            label: "GOOD MORNING",
            headline: "My done list",
            subtext: CopyBank.todayHeroInsight(count: count, hour: testHour)
        )
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .background(Color.surfaceApp)
        .frame(width: canvasWidth, height: canvasHeight, alignment: .topLeading)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        return renderer.uiImage
    }

    private func renderReflectHero(count: Int) -> UIImage? {
        let view = Hero(
            variant: .reflect,
            label: "REFLECT",
            headline: "Your day so far",
            subtext: CopyBank.reflectNote(count: count, hour: testHour)
        )
        .padding(.horizontal, 28)
        .padding(.vertical, 20)
        .background(Color.surfaceApp)
        .frame(width: canvasWidth, height: canvasHeight, alignment: .topLeading)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        return renderer.uiImage
    }

    private func attach(image: UIImage, name: String) {
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testSnapshot_today_count0() throws {
        let image = try XCTUnwrap(renderTodayHero(count: 0, threshold: 1))
        attach(image: image, name: "Hero_today_count0")
        XCTAssertGreaterThan(image.size.width, 0)
    }

    func testSnapshot_today_count1() throws {
        let image = try XCTUnwrap(renderTodayHero(count: 1, threshold: 5))
        attach(image: image, name: "Hero_today_count1")
        XCTAssertGreaterThan(image.size.width, 0)
    }

    func testSnapshot_today_atThreshold() throws {
        let image = try XCTUnwrap(renderTodayHero(count: 7, threshold: 7))
        attach(image: image, name: "Hero_today_count7_atThreshold")
        XCTAssertGreaterThan(image.size.width, 0)
    }

    func testSnapshot_today_overThreshold() throws {
        let image = try XCTUnwrap(renderTodayHero(count: 12, threshold: 7))
        attach(image: image, name: "Hero_today_count12_overThreshold")
        XCTAssertGreaterThan(image.size.width, 0)
    }

    func testSnapshot_reflect_count0() throws {
        let image = try XCTUnwrap(renderReflectHero(count: 0))
        attach(image: image, name: "Hero_reflect_count0")
        XCTAssertGreaterThan(image.size.width, 0)
    }

    func testSnapshot_reflect_count7() throws {
        let image = try XCTUnwrap(renderReflectHero(count: 7))
        attach(image: image, name: "Hero_reflect_count7")
        XCTAssertGreaterThan(image.size.width, 0)
    }
}
