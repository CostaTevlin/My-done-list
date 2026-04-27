// DoneListApp.swift
// @main entry point. Phase 1: shows "Hello" rendered with the design system
// to verify Outfit fonts + tokens load on a real device.
// Phase 2 wires the ModelContainer; Phase 3 swaps RootTabView in.
//
// Phase: 1
// See: engineering/Architecture.md  ·  decisions/0003 — SwiftData persistence

import SwiftUI
import DesignSystem

@main
struct DoneListApp: App {
    @Environment(\.scenePhase) private var phase
    // Phase 2: @State private var store = DoneStore()

    var body: some Scene {
        WindowGroup {
            // Phase 1 verification screen — replaced by RootTabView in Phase 3.
            HelloView()
        }
        // Phase 2: .modelContainer(for: DoneItem.self, isCloudKitEnabled: true)
    }
}

private struct HelloView: View {
    var body: some View {
        ZStack {
            Color.tokenWhite.ignoresSafeArea()
            VStack(spacing: Spacing.xl) {
                Text("Hello")
                    .font(.tokenBigNumeral)
                    .kerning(TypographyKerning.bigNumeral)
                    .foregroundStyle(Color.tokenCharcoal)
                Text("My Done List · Phase 1")
                    .font(.tokenLabel)
                    .kerning(TypographyKerning.label)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.tokenMid)
            }
        }
    }
}

#Preview {
    HelloView()
}

#Preview("Dark") {
    HelloView()
        .preferredColorScheme(.dark)
}
