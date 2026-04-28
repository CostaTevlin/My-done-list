// DoneListApp.swift
// @main entry point.
// Phase 1: shows "Hello" verifying Outfit fonts + tokens load.
// Phase 2: wires the SwiftData ModelContainer + scenePhase rollover + prune.
// Phase 3: replaces HelloView with RootTabView.
// Phase 7: gates the root content on `hasOnboarded`; lifts ConfettiOverlay
//          to the WindowGroup so it covers Onboarding's first-log too.
//
// See: engineering/Architecture.md  ·  decisions/0003 — SwiftData persistence

import SwiftUI
import SwiftData

@main
struct DoneListApp: App {
    @Environment(\.scenePhase) private var phase
    @State private var store = DoneStore()
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasOnboarded {
                    RootTabView()
                } else {
                    OnboardingFlow()
                }
            }
            .environment(store)
            // Confetti is global — fires on Log sheet AND on the
            // onboarding first-log step (same store.fireConfetti() path).
            .overlay {
                ConfettiOverlay(fireCount: store.confettiFireCount)
            }
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
