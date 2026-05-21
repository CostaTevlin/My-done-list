// TokenPreviewView.swift
// Dev-only consolidated preview of all Slowly token groups.
// Not linked into release builds — use only in Xcode Previews and debug schemes.
// Phase: 4.5 · D1 token scaffolding

import SwiftUI

// MARK: - Root

public struct TokenPreviewView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                NavigationLink("Colors") { ColorTokensSection() }
                NavigationLink("Typography") { FontTokensSection() }
                NavigationLink("Spacing") { SpacingTokensSection() }
                NavigationLink("Radii") { RadiiTokensSection() }
                NavigationLink("Materials") { MaterialTokensSection() }
            }
            .navigationTitle("Slowly Tokens")
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
        }
    }
}

// MARK: - Colors

private struct ColorTokensSection: View {
    private let swatches: [(String, SwiftUI.Color)] = [
        ("textPrimary",       Slowly.Color.textPrimary),
        ("textSecondary",     Slowly.Color.textSecondary),
        ("surfaceApp",        Slowly.Color.surfaceApp),
        ("surfaceGhost",      Slowly.Color.surfaceGhost),
        ("surfaceWhite",      Slowly.Color.surfaceWhite),
        ("borderDefault",     Slowly.Color.borderDefault),
        ("accentPrimary",     Slowly.Color.accentPrimary),
        ("ringLow",           Slowly.Color.ringLow),
        ("ringMid",           Slowly.Color.ringMid),
        ("ringComplete",      Slowly.Color.ringComplete),
        ("actionDestructive", Slowly.Color.actionDestructive),
    ]

    var body: some View {
        List(swatches, id: \.0) { name, color in
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.quaternary, lineWidth: 0.5))
                    .frame(width: 44, height: 44)
                Text(name)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .navigationTitle("Colors")
    }
}

// MARK: - Typography

private struct FontTokensSection: View {
    private let specimens: [(String, SwiftUI.Font)] = [
        ("bigNumeral 130",  Slowly.Font.bigNumeral),
        ("display 40",      Slowly.Font.display),
        ("h2 30",           Slowly.Font.h2),
        ("motivational 18", Slowly.Font.motivational),
        ("bodyText 16",     Slowly.Font.bodyText),
        ("bodySub 13",      Slowly.Font.bodySub),
        ("time 11",         Slowly.Font.time),
        ("chartCount 13",   Slowly.Font.chartCount),
    ]

    var body: some View {
        List(specimens, id: \.0) { name, font in
            VStack(alignment: .leading, spacing: 2) {
                Text("Ag")
                    .font(font)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                Text(name)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Typography")
    }
}

// MARK: - Spacing

private struct SpacingTokensSection: View {
    private let steps: [(String, CGFloat)] = [
        ("xs  8",            Slowly.Spacing.xs),
        ("sm  12",           Slowly.Spacing.sm),
        ("md  16",           Slowly.Spacing.md),
        ("lg  20",           Slowly.Spacing.lg),
        ("xl  24",           Slowly.Spacing.xl),
        ("xxl 32",           Slowly.Spacing.xxl),
        ("xxxl 40",          Slowly.Spacing.xxxl),
        ("screenTop  27",    Slowly.Spacing.screenTop),
        ("screenBottom 62",  Slowly.Spacing.screenBottom),
    ]

    var body: some View {
        List(steps, id: \.0) { label, value in
            HStack(spacing: 12) {
                Rectangle()
                    .fill(Slowly.Color.accentPrimary)
                    .frame(width: value, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                Text(label)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .navigationTitle("Spacing")
    }
}

// MARK: - Radii

private struct RadiiTokensSection: View {
    private let radii: [(String, CGFloat)] = [
        ("card",     Slowly.Radius.card),
        ("sheet",    Slowly.Radius.sheet),
        ("button",   Slowly.Radius.button),
        ("fab",      Slowly.Radius.fab),
        ("ringInset", Slowly.Radius.ringInset),
    ]

    var body: some View {
        List(radii, id: \.0) { name, r in
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: r == 0 ? 0 : r)
                    .stroke(Slowly.Color.accentPrimary, lineWidth: 2)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.system(.body, design: .monospaced))
                    Text(r == 0 ? "TBD" : "\(Int(r))pt")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Radii (TBD)")
    }
}

// MARK: - Materials

private struct MaterialTokensSection: View {
    var body: some View {
        List {
            Section("iOS 18 fallback") {
                ZStack {
                    Slowly.Color.surfaceGhost
                    Text("ultraThinMaterial")
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Slowly.Material.fallback)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .frame(height: 80)
                .listRowInsets(.init())
            }

            if #available(iOS 26.0, *) {
                Section("iOS 26 Glass spec values") {
                    ParamRow("frost",       Slowly.Material.frost)
                    ParamRow("splay",       Slowly.Material.splay)
                    ParamRow("refraction",  Slowly.Material.refraction)
                    ParamRow("dispersion",  Slowly.Material.dispersion)
                    ParamRow("depth",       Slowly.Material.depth)
                    ParamRow("lightAngle",  Slowly.Material.lightAngle)
                    ParamRow("opacity",     Slowly.Material.opacity)
                }
            }
        }
        .navigationTitle("Materials")
    }
}

private struct ParamRow: View {
    let label: String
    let value: CGFloat
    init(_ label: String, _ value: CGFloat) { self.label = label; self.value = value }
    var body: some View {
        HStack {
            Text(label).font(.system(.body, design: .monospaced))
            Spacer()
            Text("\(value, specifier: "%.0f")").foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    TokenPreviewView()
        .preferredColorScheme(.light)
}

#Preview("Dark (v1 parity)") {
    TokenPreviewView()
        .preferredColorScheme(.dark)
}
