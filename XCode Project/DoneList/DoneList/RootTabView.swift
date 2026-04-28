// RootTabView.swift
// Top-level navigation shell: TabView with Today + Reflect tabs.
//
// Phase 3 builds the shell + wires Today fully. The floating "+ Log" pill
// (`.tabViewBottomAccessory` on iOS 26 / overlay on iOS 18-25) and Settings
// entry point are left to Phase 4 / Phase 6 respectively. The `showLog` state
// is plumbed now so Phase 4 only needs to attach a `.sheet` modifier.
//
// Phase: 3
// See: engineering/Architecture.md  ·  design-system/Liquid Glass mapping.md  ·  ADR-0005

import SwiftUI

struct RootTabView: View {
    @State private var showLog: Bool = false

    var body: some View {
        TabView {
            TodayView(onLogTap: { showLog = true })
                .tabItem { Label("Today", systemImage: "circle.fill") }

            ReflectView()
                .tabItem { Label("Reflect", systemImage: "chart.bar.fill") }
        }
        // Phase 4: attach `.sheet(isPresented: $showLog) { LogSheet() }` here
        // and add the `.tabViewBottomAccessory` / overlay log pill that flips
        // `showLog`. Keeping the binding here so the empty-state CTA in Today
        // can wire through immediately.
    }
}
