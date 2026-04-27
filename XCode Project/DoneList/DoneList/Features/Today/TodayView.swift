// TodayView.swift
// The hero screen. Greeting · big counter · motivational copy · today's items.
//
// Phase: 3
// See: design-system/Screen specs.md (Today)

import SwiftUI
import SwiftData

struct TodayView: View {
    var body: some View {
        // Phase 3 implementation
        Text("Today")
    }
}

#Preview("Empty") {
    TodayView()
        .modelContainer(for: DoneItem.self, inMemory: true)
}
