// DoneListWidget.swift
// @main entry for the WidgetKit extension bundle.
//
// Phase: 8
// See: engineering/Architecture.md (Widget)  ·  decisions/0008 — 4.2 risk mitigation

import WidgetKit
import SwiftUI

@main
struct DoneListWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        // Phase 8: LockScreenAccessory()
    }
}

struct TodayWidget: Widget {
    let kind: String = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today")
        .description("How many things you've logged today.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, count: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(TodayEntry(date: .now, count: 0))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        // Phase 8: read shared App Group SwiftData store
        let timeline = Timeline(entries: [TodayEntry(date: .now, count: 0)], policy: .atEnd)
        completion(timeline)
    }
}

struct TodayEntry: TimelineEntry {
    let date: Date
    let count: Int
}

struct TodayWidgetView: View {
    let entry: TodayEntry

    var body: some View {
        // Phase 8 implementation
        Text(entry.count, format: .number)
            .font(.system(size: 48, weight: .ultraLight))
            .widgetURL(URL(string: "donelist://log"))
    }
}
