// DoneListApp.swift
// @main entry point.
// Phase 1: shows "Hello" verifying Outfit fonts + tokens load.
// Phase 2: wires the SwiftData ModelContainer + scenePhase rollover + prune.
// Phase 3: replaces HelloView with RootTabView.
//
// See: engineering/Architecture.md  ·  decisions/0003 — SwiftData persistence

import SwiftUI
import SwiftData
import DesignSystem

@main
struct DoneListApp: App {
    @Environment(\.scenePhase) private var phase
    @State private var store = DoneStore()

    var body: some Scene {
        WindowGroup {
            HelloView()
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

private struct HelloView: View {
    @Environment(DoneStore.self) private var store
    @Query(sort: \DoneItem.createdAt, order: .reverse) private var allItems: [DoneItem]

    private var todayCount: Int {
        allItems.filter { $0.date == store.todayKeyValue }.count
    }

    var body: some View {
        ZStack {
            Color.tokenWhite.ignoresSafeArea()
            VStack(spacing: Spacing.xl) {
                Text("Hello")
                    .font(.tokenBigNumeral)
                    .kerning(TypographyKerning.bigNumeral)
                    .foregroundStyle(Color.tokenCharcoal)

                Text("My Done List · Phase 2")
                    .font(.tokenLabel)
                    .kerning(TypographyKerning.label)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.tokenMid)

                // Phase 2 verification: items persist across launches.
                VStack(spacing: Spacing.sm) {
                    Text("\(todayCount) logged today")
                        .font(.tokenBody)
                        .foregroundStyle(Color.tokenDark)

                    Button("Add test item") {
                        store.add(text: "Test \(Date.now.timeIntervalSince1970.rounded())")
                    }
                    .buttonStyle(PillButtonStyle())
                }
                .padding(.top, Spacing.xxxl)
            }
        }
    }
}
