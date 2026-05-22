// DSIcon.swift
// SF Symbol wrapper for Slowly-branded icon usage.
// Sizes: sm 16 · md 20 · lg 24 · xl 28 · custom(pt)
// Default color: Slowly.Color.textPrimary. Override for secondary or accent contexts.
// Phase: 4.5 · D2 primitives
// Source of truth: Figma Slowly-MVP › Iconography

import SwiftUI

public struct DSIcon: View {

    public enum Size: Equatable {
        case sm
        case md
        case lg
        case xl
        case custom(CGFloat)

        public var points: CGFloat {
            switch self {
            case .sm:            16
            case .md:            20
            case .lg:            24
            case .xl:            28
            case .custom(let pt): pt
            }
        }
    }

    private let symbol: String
    private let size: Size
    private let color: SwiftUI.Color

    public init(_ symbol: String, size: Size = .md, color: SwiftUI.Color = Slowly.Color.textPrimary) {
        self.symbol = symbol
        self.size = size
        self.color = color
    }

    public var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size.points))
            .foregroundStyle(color)
    }
}

#Preview("DSIcon") {
    HStack(spacing: Slowly.Spacing.lg) {
        DSIcon("mic.fill", size: .sm)
        DSIcon("mic.fill", size: .md)
        DSIcon("mic.fill", size: .lg)
        DSIcon("mic.fill", size: .xl)
        DSIcon("checkmark", size: .md, color: Slowly.Color.accentPrimary)
        DSIcon("xmark", size: .md, color: Slowly.Color.textSecondary)
    }
    .padding(Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}
