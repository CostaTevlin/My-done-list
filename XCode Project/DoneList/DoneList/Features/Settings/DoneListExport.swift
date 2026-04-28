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
    }

    static let currentVersion = 1

    /// Build an export from a `DoneItem` array — sorted ascending by
    /// `createdAt` so the file reads chronologically.
    static func from(items: [DoneItem], now: Date = .now) -> DoneListExport {
        let mapped = items
            .sorted { $0.createdAt < $1.createdAt }
            .map { Item(text: $0.text, time: $0.time, date: $0.date, createdAt: $0.createdAt) }
        return DoneListExport(
            exportVersion: currentVersion,
            exportedAt: now,
            items: mapped
        )
    }

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func encoded() throws -> Data {
        try Self.encoder.encode(self)
    }
}

// MARK: - Transferable

extension DoneListExport: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { export in
            try export.encoded()
        }
        .suggestedFileName { _ in
            "done-list-\(yyyyMMdd(.now)).json"
        }
    }
}

private let exportDayFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = .current
    f.dateFormat = "yyyy-MM-dd"
    return f
}()

private func yyyyMMdd(_ date: Date) -> String {
    exportDayFormatter.string(from: date)
}
