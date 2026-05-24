// TodayScreenNewSnapshotTests.swift
// Visual capture for R4 screens: TodayScreen_New (empty + populated) and
// AddEntrySheet_New (text-mode). Mirrors RootViewSnapshotTests pattern.
//
// Phase: R4 (ADR-0010)

import XCTest
import SwiftUI
import SwiftData
@testable import DoneList
import DesignSystem

@MainActor
final class TodayScreenNewSnapshotTests: XCTestCase {

    private let canvasWidth: CGFloat = 393
    private let canvasHeight: CGFloat = 852

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

    // MARK: - Empty state

    func testSnapshot_todayScreenNew_empty_iOS18() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
        let store = DoneStore(context: container.mainContext)

        let view = TodayScreen_New(onLog: { _ in }, onEditItem: { _ in })
            .environment(store)
            .modelContainer(container)
            .frame(width: canvasWidth, height: canvasHeight)

        try render(view, name: "TodayScreen_New_empty_iOS18")
    }

    // MARK: - Populated state (morning + afternoon + voice item)

    func testSnapshot_todayScreenNew_populated_iOS18() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
        let ctx = container.mainContext
        let today = DoneStore.todayKey()

        ctx.insert(DoneItem(text: "Morning stand-up done", time: "09:15", date: today,
                            createdAt: .now.addingTimeInterval(-5400), source: .text))
        ctx.insert(DoneItem(text: "Said something out loud", time: "14:32", date: today,
                            createdAt: .now.addingTimeInterval(-3600), source: .voice))
        ctx.insert(DoneItem(text: "Reviewed the deck", time: "15:00", date: today,
                            createdAt: .now.addingTimeInterval(-1800), source: .text))
        ctx.insert(DoneItem(text: "Evening walk", time: "19:45", date: today,
                            createdAt: .now.addingTimeInterval(-900), source: .text))

        let store = DoneStore(context: ctx)

        let view = TodayScreen_New(onLog: { _ in }, onEditItem: { _ in })
            .environment(store)
            .modelContainer(container)
            .frame(width: canvasWidth, height: canvasHeight)

        try render(view, name: "TodayScreen_New_populated_iOS18")
    }

    // MARK: - AddEntrySheet_New text-mode

    func testSnapshot_addEntrySheetNew_textMode_iOS18() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
        let store = DoneStore(context: container.mainContext)

        let view = AddEntrySheet_New(editingItem: nil)
            .environment(store)
            .modelContainer(container)
            .frame(width: canvasWidth, height: 600)

        try render(view, name: "AddEntrySheet_New_textMode_iOS18")
    }
}
