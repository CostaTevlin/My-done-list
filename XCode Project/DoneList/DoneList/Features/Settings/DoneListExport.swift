// DoneListExport.swift
// Pure / `Codable` snapshot of every logged item used for the "Export as JSON"
// flow in Settings. Wraps the array under a top-level object so the file is
// self-describing (export version + timestamp) and easy to evolve.
//
// Phase: 6
// See: design-system/Screen specs.md (Settings · Data section)

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

/// On-disk shape of a JSON export.
struct DoneListExport: Codable, Equatable {
    /// Bumped if the schema changes — readers should validate before importing.
    let exportVersion: Int
    let exportedAt: Date
    let items: [Item]

    struct Item: Codable, Equatable {
        let text: String
        let time: String
        let date: String
        let createdAt: Date

        private enum CodingKeys: String, CodingKey { case text, time, date, createdAt }

        nonisolated func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(text, forKey: .text)
            try container.encode(time, forKey: .time)
            try container.encode(date, forKey: .date)
            try container.encode(createdAt, forKey: .createdAt)
        }
    }

    static let currentVersion = 1

    nonisolated static func defaultFilename(for date: Date) -> String {
        "done-list-\(yyyyMMdd(date)).json"
    }

    nonisolated static func yyyyMMdd(_ date: Date) -> String {
        // Thread-safe date formatting without shared DateFormatter.
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = .current
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        let y = comps.year ?? 1970
        let m = comps.month ?? 1
        let d = comps.day ?? 1
        return String(format: "%04d-%02d-%02d", y, m, d)
    }

    /// Build an export from a `DoneItem` array — sorted ascending by
    /// `createdAt` so the file reads chronologically.
    /// `exportedAt` is truncated to whole seconds so ISO-8601 round-trips are lossless.
    static func from(items: [DoneItem], now: Date = .now) -> DoneListExport {
        let exportedAt = Date(timeIntervalSinceReferenceDate: now.timeIntervalSinceReferenceDate.rounded(.down))
        let mapped = items
            .sorted { $0.createdAt < $1.createdAt }
            .map { Item(text: $0.text, time: $0.time, date: $0.date, createdAt: $0.createdAt) }
        return DoneListExport(
            exportVersion: currentVersion,
            exportedAt: exportedAt,
            items: mapped
        )
    }

    private enum CodingKeys: String, CodingKey { case exportVersion, exportedAt, items }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(exportVersion, forKey: .exportVersion)
        try container.encode(exportedAt, forKey: .exportedAt)
        try container.encode(items, forKey: .items)
    }

    nonisolated func encoded() throws -> Data {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return try e.encode(self)
    }

    /// Decodes an export payload produced by `encoded()`.
    /// Must use `.iso8601` to match the encoder's date strategy.
    nonisolated static func decode(from data: Data) throws -> DoneListExport {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return try d.decode(DoneListExport.self, from: data)
    }
}

// MARK: - Nonisolated Codable / Equatable

// Swift synthesises Decodable and Equatable conformances as main-actor-isolated
// unless they are explicitly declared nonisolated. Extensions in the same file
// can access the private CodingKeys and still leave the struct's memberwise
// initialisers intact (body-level inits suppress them; extension inits do not).

extension DoneListExport {
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        exportVersion = try c.decode(Int.self, forKey: .exportVersion)
        exportedAt    = try c.decode(Date.self, forKey: .exportedAt)
        items         = try c.decode([Item].self, forKey: .items)
    }

    nonisolated static func == (lhs: DoneListExport, rhs: DoneListExport) -> Bool {
        lhs.exportVersion == rhs.exportVersion &&
        lhs.exportedAt    == rhs.exportedAt &&
        lhs.items         == rhs.items
    }
}

extension DoneListExport.Item {
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        text      = try c.decode(String.self, forKey: .text)
        time      = try c.decode(String.self, forKey: .time)
        date      = try c.decode(String.self, forKey: .date)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    nonisolated static func == (lhs: DoneListExport.Item, rhs: DoneListExport.Item) -> Bool {
        lhs.text == rhs.text &&
        lhs.time == rhs.time &&
        lhs.date == rhs.date &&
        lhs.createdAt == rhs.createdAt
    }
}

// MARK: - Transferable

extension DoneListExport: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { export in
            try export.encoded()
        }
        .suggestedFileName { _ in
            DoneListExport.defaultFilename(for: Date())
        }
    }
}

