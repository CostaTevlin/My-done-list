// DSDivider.swift
// Slowly-branded 1pt horizontal divider using borderDefault token.
// Replaces the system Divider() in Slowly-branded surfaces — borderDefault (#e8e9e6)
// is slightly warmer and lower-contrast than the system separator.
// Phase: 4.5 · D2 primitives
// Source of truth: Figma Slowly-MVP › "Color/Border/Default" + row separator specs

import SwiftUI

public struct DSDivider: View {
    public init() {}

    public var body: some View {
        Rectangle()
            .fill(Slowly.Color.borderDefault)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}

#Preview("DSDivider") {
    VStack(spacing: 0) {
        Text("Row above").dsText(.bodyRegular)
            .padding(Slowly.Spacing.md)
        DSDivider()
        Text("Row below").dsText(.bodyRegular)
            .padding(Slowly.Spacing.md)
    }
    .background(Slowly.Color.surfaceApp)
}
