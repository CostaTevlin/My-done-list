// LogSheetSnapshotTests.swift
// Visual capture tests for LogSheet voice and text modes.
// Uses ImageRenderer + XCTAttachment (same pattern as TodayHeroSnapshotTests).
//
// Phase: 4.5 (ADR-0010)

import XCTest
import SwiftUI
import SwiftData
@testable import DoneList
import DesignSystem

@MainActor
final class LogSheetSnapshotTests: XCTestCase {

    private let canvasWidth: CGFloat = 393
    private let canvasHeight: CGFloat = 600

    // MARK: - Helpers

    private func makeStore() throws -> DoneStore {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
        return DoneStore(context: container.mainContext)
    }

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

    // MARK: - Voice idle (no transcript)

    func testSnapshot_voiceIdle_iOS18() throws {
        let store = try makeStore()
        let view = LogSheet(initialMode: .voice)
            .environment(store)
            .frame(width: canvasWidth, height: canvasHeight)
            .background(Color.surfaceApp)
        try render(view, name: "LogSheet_voice_idle_iOS18")
    }

    // MARK: - Text mode

    func testSnapshot_textMode_iOS18() throws {
        let store = try makeStore()
        let view = LogSheet(initialMode: .text)
            .environment(store)
            .frame(width: canvasWidth, height: canvasHeight)
            .background(Color.surfaceApp)
        try render(view, name: "LogSheet_text_iOS18")
    }

    // MARK: - Edit existing mode (voice toggle hidden)

    func testSnapshot_editMode_voiceToggleHidden_iOS18() throws {
        let store = try makeStore()
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
        let item = DoneItem(
            text: "Finished the deck",
            time: "14:32",
            date: DoneStore.todayKey(),
            createdAt: .now
        )
        container.mainContext.insert(item)
        let view = LogSheet(initialMode: .text, editingItem: item)
            .environment(store)
            .frame(width: canvasWidth, height: canvasHeight)
            .background(Color.surfaceApp)
        try render(view, name: "LogSheet_editMode_iOS18")
    }
}
