// RootViewSnapshotTests.swift
// Visual capture tests for RootView shell — FAB + TopControls + GhostInputRow.
// Uses ImageRenderer + XCTAttachment.
//
// Phase: 4.5 (ADR-0010)

import XCTest
import SwiftUI
import SwiftData
@testable import DoneList
import DesignSystem

@MainActor
final class RootViewSnapshotTests: XCTestCase {

    private let canvasWidth: CGFloat = 393
    private let canvasHeight: CGFloat = 852    // iPhone 15 Pro logical height

    private func render<V: View>(_ view: V, name: String) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let image = try XCTUnwrap(renderer.uiImage, "ImageRenderer returned nil for \(name)")
        let attachment = XCTAttachment(image: image)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertGreaterThan(image.size.width, 0)
    }

    // MARK: - Empty Today + FAB + TopControls

    func testSnapshot_emptyToday_iOS18() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
        let store = DoneStore(context: container.mainContext)

        let view = RootTabView()
            .environment(store)
            .modelContainer(container)
            .frame(width: canvasWidth, height: canvasHeight)
            .background(Color.surfaceApp)

        try render(view, name: "RootView_empty_iOS18")
    }

    // MARK: - Populated Today + FAB + TopControls + GhostInputRow

    func testSnapshot_populatedToday_iOS18() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
        let ctx = container.mainContext
        let today = DoneStore.todayKey()
        ctx.insert(DoneItem(text: "Took a 10-min walk", time: "14:32", date: today, createdAt: .now))
        ctx.insert(DoneItem(text: "Finished the budget spreadsheet", time: "13:15", date: today,
                            createdAt: .now.addingTimeInterval(-600)))
        let store = DoneStore(context: ctx)

        let view = RootTabView()
            .environment(store)
            .modelContainer(container)
            .frame(width: canvasWidth, height: canvasHeight)
            .background(Color.surfaceApp)

        try render(view, name: "RootView_populated_iOS18")
    }
}
