// PulseRingSnapshotTests.swift
// Visual capture tests for PulseRing component: animated and Reduce Motion states.
// Uses ImageRenderer + XCTAttachment.
//
// Phase: 4.5 (ADR-0010, ADR-0006)

import XCTest
import SwiftUI
@testable import DoneList
import DesignSystem

@MainActor
final class PulseRingSnapshotTests: XCTestCase {

    private func render<V: View>(_ view: V, name: String) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3
        let image = try XCTUnwrap(renderer.uiImage, "ImageRenderer returned nil for \(name)")
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertGreaterThan(image.size.width, 0)
    }

    // MARK: - Pulsing state (animation paused at render time — captures first frame)

    func testSnapshot_pulsing() throws {
        let view = PulseRing(isPulsing: true)
            .padding(Spacing.xl)
            .background(Color.surfaceApp)

        try render(view, name: "PulseRing_pulsing")
    }

    // MARK: - Idle state (no pulse)

    func testSnapshot_idle() throws {
        let view = PulseRing(isPulsing: false)
            .padding(Spacing.xl)
            .background(Color.surfaceApp)

        try render(view, name: "PulseRing_idle")
    }

    // MARK: - Reduce Motion / static fallback
    // isPulsing: false triggers the same static double-ring path as Reduce Motion ON.
    // This exercises the static branch without requiring a writable env key.

    func testSnapshot_static_doubleRing() throws {
        let view = PulseRing(isPulsing: false)
            .padding(Spacing.xl)
            .background(Color.surfaceApp)

        try render(view, name: "PulseRing_static_doubleRing")
    }
}
