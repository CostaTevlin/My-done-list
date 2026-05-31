// DoneListApp.swift
// @main entry point.
// Phase 1: shows "Hello" verifying tokens load.
// Phase 2: wires the SwiftData ModelContainer + scenePhase rollover + prune.
// Phase 3: replaces HelloView with RootTabView.
// Phase 7: gates the root content on `hasOnboarded`; lifts ConfettiOverlay
//          to the WindowGroup so it covers Onboarding's first-log too.
// R4: ConfettiOverlay moved into RootTabView (so it is no longer WindowGroup-level).
//
// See: engineering/Architecture.md  ·  decisions/0003 — SwiftData persistence

import SwiftUI
import SwiftData

#Preview("Confetti") {
    @Previewable @State var show = false
    Button("Fire 🎉") { show = true }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay { ConfettiView(isPresented: $show) }
}

@main
struct DoneListApp: App {
    @Environment(\.scenePhase) private var phase
    @State private var store = DoneStore()
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "dark"

    private var preferredColorScheme: ColorScheme? {
        switch colorSchemePreference {
        case "dark":  return .dark
        case "light": return .light
        default:      return nil
        }
    }

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
            .preferredColorScheme(preferredColorScheme)
        }
        .modelContainer(DoneStore.container)
        .onChange(of: phase) { _, newPhase in
            guard newPhase == .active else { return }
            store.recomputeTodayKey()

            // Defer the daily prune past first paint. `pruneIfNeeded` does
            // a SwiftData fetch + N deletes + save on the MainActor —
            // running it synchronously on `.active` blocks the launch frame
            // on the day it fires. 500ms pushes it past the interactive
            // moment. For a fully-decoupled version, switch `pruneIfNeeded`
            // to a detached background ModelContext.
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(500))
                store.pruneIfNeeded()
            }
        }
    }
}
