// DoneListExportTests.swift
// Phase 6 — verifies the JSON export shape: chronological ordering,
// version field, ISO-8601 dates, and round-trip stability.
//
// See: design-system/Screen specs.md (Settings · Data section)

import Testing
import Foundation
@testable import DoneList

@Suite(.serialized)
struct DoneListExportTests {

    // MARK: - Helpers

    private static func makeItem(
        text: String,
        time: String = "10:00",
        date: String = "2026-04-28",
        offset: TimeInterval = 0
    ) -> DoneItem {
        DoneItem(
            text: text,
            time: time,
            date: date,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000 + offset)
        )
    }

    // MARK: - Shape

    @Test("export carries the current schema version")
    func export_versionFieldPresent() {
        let export = DoneListExport.from(items: [])
        #expect(export.exportVersion == DoneListExport.currentVersion)
        #expect(export.exportVersion == 1)
    }

    @Test("export from empty input produces zero items")
    func export_emptyInput() {
        let export = DoneListExport.from(items: [])
        #expect(export.items.isEmpty)
    }

    @Test("export sorts items chronologically by createdAt ascending")
    func export_chronologicalOrder() {
        let items = [
            Self.makeItem(text: "third", offset: 200),
            Self.makeItem(text: "first", offset: 0),
            Self.makeItem(text: "second", offset: 100),
        ]
        let export = DoneListExport.from(items: items)
        #expect(export.items.map(\.text) == ["first", "second", "third"])
    }

    @Test("export preserves all four fields per item")
    func export_fieldFidelity() {
        let item = Self.makeItem(text: "Took a 10-min walk", time: "14:32", date: "2026-04-28")
        let export = DoneListExport.from(items: [item])
        let only = try? #require(export.items.first)
        #expect(only?.text == "Took a 10-min walk")
        #expect(only?.time == "14:32")
        #expect(only?.date == "2026-04-28")
        #expect(only?.createdAt == item.createdAt)
    }

    // MARK: - Encoding

    @Test("encoded payload is valid JSON containing the expected top-level keys")
    func encoded_isJSON() throws {
        let export = DoneListExport.from(items: [Self.makeItem(text: "hello")])
        let data = try export.encoded()
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let unwrapped = try #require(json)
        #expect(unwrapped["exportVersion"] as? Int == 1)
        #expect(unwrapped["exportedAt"] is String)              // ISO-8601 string
        #expect(unwrapped["items"] is [[String: Any]])
    }

    @Test("encoded payload uses ISO-8601 dates")
    func encoded_iso8601Dates() throws {
        let export = DoneListExport.from(items: [Self.makeItem(text: "hello")])
        let data = try export.encoded()
        let string = try #require(String(data: data, encoding: .utf8))
        // ISO-8601 strings start with `YYYY-MM-DDTHH:`
        let regex = try NSRegularExpression(pattern: #"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"#)
        let range = NSRange(location: 0, length: (string as NSString).length)
        #expect(regex.firstMatch(in: string, range: range) != nil)
    }

    @Test("export round-trips through JSON encoding")
    func encoded_roundTrip() throws {
        let items = [
            Self.makeItem(text: "first", offset: 0),
            Self.makeItem(text: "second", offset: 60),
        ]
        let original = DoneListExport.from(items: items)
        let data = try original.encoded()
        let decoded = try JSONDecoder().decode(DoneListExport.self, from: data)
        #expect(decoded == original)
    }
}
