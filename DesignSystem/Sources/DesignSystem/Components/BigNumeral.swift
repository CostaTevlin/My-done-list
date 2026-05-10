// BigNumeral.swift
// The hero counter. 96pt SF Pro Display Regular, tokenInk.
// Phase: 1 (placeholder), Phase 3 (wired), Phase 5 (SF Pro + sage migration)
// See: design-system/Components.md (BigNumeral)

import SwiftUI

public struct BigNumeral: View {
    public let value: Int

    public init(value: Int) {
        self.value = value
    }

    public var body: some View {
        Text(padded(value))
            .font(.bigNumeral)
            .foregroundStyle(Color.tokenInk)
            .contentTransition(.numericText())
            .dynamicTypeSize(.xSmall ... DynamicTypeSize.xxLarge)
            .accessibilityLabel("\(value) \(value == 1 ? "thing" : "things") logged today")
    }

    private func padded(_ n: Int) -> String {
        return n < 10 ? "0\(n)" : "\(n)"
    }
}
