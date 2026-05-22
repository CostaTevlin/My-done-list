// LogSheetModeTests.swift
// Logical tests for LogSheet behavior that don't require full UI rendering.
// Verifies store interactions (edit vs insert), mode enum, and CopyBank strings.
//
// Phase: 4.5 (ADR-0010)

import Testing
import SwiftData
import Foundation
@testable import DoneList

// MARK: - Helper

private func makeStore() throws -> (DoneStore, ModelContext) {
    let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: DoneItem.self, configurations: cfg)
    let ctx = ModelContext(container)
    return (DoneStore(context: ctx), ctx)
}

// MARK: - InputMode

@Suite("InputMode enum")
struct InputModeTests {

    @Test("InputMode has voice and text cases")
    func inputMode_cases() {
        let voice: InputMode = .voice
        let text: InputMode = .text
        #expect(voice != text)
    }
}

// MARK: - LogSheet store interactions (edit vs insert)

@Suite("LogSheet store interactions")
struct LogSheetStoreTests {

    @Test("update mutates existing item, does not insert a new one")
    func testEditingItemUpdatesNotInserts() throws {
        let (store, ctx) = try makeStore()
        let original = DoneItem(
            text: "Original text",
            time: DoneStore.timeKey(),
            date: DoneStore.todayKey(),
            createdAt: .now
        )
        ctx.insert(original)
        try ctx.save()

        store.update(original, text: "Updated text")

        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.count == 1, "update must not insert a new item")
        #expect(all.first?.text == "Updated text")
    }

    @Test("add creates a new item when no editingItem")
    func testAddCreatesNewItem() throws {
        let (store, ctx) = try makeStore()
        store.add(text: "New item")
        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.count == 1)
        #expect(all.first?.text == "New item")
    }

    @Test("update ignores text shorter than 2 chars")
    func testUpdateIgnoresShortText() throws {
        let (store, ctx) = try makeStore()
        let item = DoneItem(
            text: "Keep this",
            time: DoneStore.timeKey(),
            date: DoneStore.todayKey(),
            createdAt: .now
        )
        ctx.insert(item)
        try ctx.save()

        store.update(item, text: " ")

        let all = try ctx.fetch(FetchDescriptor<DoneItem>())
        #expect(all.first?.text == "Keep this", "update with < 2 chars must be ignored")
    }
}

// MARK: - CopyBank voice strings

@Suite("CopyBank voice strings")
struct CopyBankVoiceStringTests {

    @Test("logSheetTitle is non-empty")
    func logSheetTitle_nonEmpty() {
        #expect(!CopyBank.logSheetTitle.isEmpty)
    }

    @Test("voiceTrySayingExample is non-empty")
    func voiceTrySayingExample_nonEmpty() {
        #expect(!CopyBank.voiceTrySayingExample.isEmpty)
    }

    @Test("voiceListeningCaption contains 'Listening'")
    func voiceListeningCaption_containsListening() {
        #expect(CopyBank.voiceListeningCaption.lowercased().contains("listening"))
    }

    @Test("voiceModeToggleToText and voiceModeToggleToVoice are distinct")
    func modeToggleLabels_distinct() {
        #expect(CopyBank.voiceModeToggleToText != CopyBank.voiceModeToggleToVoice)
    }

    @Test("ghostInputPlaceholder is non-empty")
    func ghostInputPlaceholder_nonEmpty() {
        #expect(!CopyBank.ghostInputPlaceholder.isEmpty)
    }
}
