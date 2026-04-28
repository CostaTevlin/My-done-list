// DoneListApp.swift
// @main entry point.
// Phase 1: shows "Hello" verifying Outfit fonts + tokens load.
// Phase 2: wires the SwiftData ModelContainer + scenePhase rollover + prune.
// Phase 3: replaces HelloView with RootTabView.
//
// See: engineering/Architecture.md  ·  decisions/0003 — SwiftData persistence

import SwiftUI
import SwiftData

@main
struct DoneListApp: App {
    @Environment(\.scenePhase) private var phase
    @State private var store = DoneStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(store)
        }
        .modelContainer(DoneStore.container)
        .onChange(of: phase) { _, newPhase in
            if newPhase == .active {
                store.recomputeTodayKey()
                store.pruneIfNeeded()
            }
        }
    }
}
