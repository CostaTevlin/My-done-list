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
                Section("D1 Tokens") {
                    NavigationLink("Colors") { ColorTokensSection() }
                    NavigationLink("Typography") { FontTokensSection() }
                    NavigationLink("Spacing") { SpacingTokensSection() }
                    NavigationLink("Radii") { RadiiTokensSection() }
                    NavigationLink("Materials") { MaterialTokensSection() }
                }
                Section("D2 Primitives") {
                    NavigationLink("Text styles") { D2TextSection() }
                    NavigationLink("Buttons") { D2ButtonSection() }
                    NavigationLink("Icons") { D2IconSection() }
                    NavigationLink("Divider & TextField") { D2UtilitySection() }
                    NavigationLink("Checkmark") { D2CheckmarkSection() }
                }
                Section("D3 Composites") {
                    NavigationLink("Adaptive Hero") { D3AdaptiveHeroSection() }
                    NavigationLink("Entry Row") { D3EntryRowSection() }
                    NavigationLink("Section Header") { D3SectionHeaderSection() }
                    NavigationLink("Nav Bar Plain") { D3NavBarSection() }
                    NavigationLink("Tab Bar Main") { D3TabBarSection() }
                    NavigationLink("Week Bar Chart") { D3WeekBarChartSection() }
                    NavigationLink("Confirmation Block") { D3ConfirmationSection() }
                    NavigationLink("Voice Capture Button") { D3VoiceCaptureSection() }
                    NavigationLink("Empty State Arrow") { D3EmptyStateArrowSection() }
                }
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
        ("textPrimary",          Slowly.Color.textPrimary),
        ("textSecondary",        Slowly.Color.textSecondary),
        ("textPrimaryWhite",     Slowly.Color.textPrimaryWhite),
        ("textSecondaryWhite",   Slowly.Color.textSecondaryWhite),
        ("surfaceApp",           Slowly.Color.surfaceApp),
        ("surfaceGhost",         Slowly.Color.surfaceGhost),
        ("borderDefault",        Slowly.Color.borderDefault),
        ("accentPrimary",        Slowly.Color.accentPrimary),
        ("ringLow",              Slowly.Color.ringLow),
        ("ringMid",              Slowly.Color.ringMid),
        ("ringComplete",         Slowly.Color.ringComplete),
        ("neutral50",            Slowly.Color.neutral50),
        ("sage50",               Slowly.Color.sage50),
        ("actionDestructive",    Slowly.Color.actionDestructive),
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
        ("bigNumeral 130",      Slowly.Font.bigNumeral),
        ("titleDisplay 60",     Slowly.Font.titleDisplay),
        ("title1Light 40",      Slowly.Font.title1Light),
        ("title2Light 30",      Slowly.Font.title2Light),
        ("headlineRegular 18",  Slowly.Font.headlineRegular),
        ("bodyRegular 16",      Slowly.Font.bodyRegular),
        ("bodyMedium 16·md",    Slowly.Font.bodyMedium),
        ("footnoteRegular 13",  Slowly.Font.footnoteRegular),
        ("footnoteMedium 13·md",Slowly.Font.footnoteMedium),
        ("captionRegular 11",   Slowly.Font.captionRegular),
        ("captionBold 11·bd",   Slowly.Font.captionBold),
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

// MARK: - D2 Primitives Gallery

private struct D2TextSection: View {
    var body: some View {
        List {
            ForEach(DSTextStyle.allCases, id: \.self) { style in
                Text("Ag — \(String(describing: style))").dsText(style)
                    .padding(.vertical, 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            DSDivider()
            Text("textSecondary").dsText(.bodyRegular, color: Slowly.Color.textSecondary)
            Text("accentPrimary").dsText(.bodyMedium, color: Slowly.Color.accentPrimary)
        }
        .navigationTitle("Text styles")
    }
}

private struct D2ButtonSection: View {
    var body: some View {
        List {
            Section("Primary") {
                Button("Save done") {}.buttonStyle(DSButtonStyle(.primary))
            }
            Section("Secondary") {
                Button("Cancel") {}.buttonStyle(DSButtonStyle(.secondary))
            }
            Section("FAB — 56pt") {
                HStack(spacing: Slowly.Spacing.lg) {
                    DSFABButton(icon: "plus", accessibilityLabel: "Add") {}
                    DSFABButton(icon: "mic.fill", accessibilityLabel: "Voice log") {}
                }
            }
        }
        .navigationTitle("Buttons")
    }
}

private struct D2IconSection: View {
    private let symbols = ["mic.fill", "checkmark", "xmark", "magnifyingglass", "chart.bar", "ellipsis"]
    private let sizes: [(String, DSIcon.Size)] = [("sm 16", .sm), ("md 20", .md), ("lg 24", .lg), ("xl 28", .xl)]

    var body: some View {
        List {
            ForEach(sizes, id: \.0) { label, size in
                Section(label) {
                    HStack(spacing: Slowly.Spacing.md) {
                        ForEach(symbols, id: \.self) { sym in
                            DSIcon(sym, size: size)
                        }
                    }
                    .padding(.vertical, Slowly.Spacing.xs)
                }
            }
            Section("Colors") {
                HStack(spacing: Slowly.Spacing.md) {
                    DSIcon("star.fill", size: .md)
                    DSIcon("star.fill", size: .md, color: Slowly.Color.textSecondary)
                    DSIcon("star.fill", size: .md, color: Slowly.Color.accentPrimary)
                    DSIcon("star.fill", size: .md, color: Slowly.Color.actionDestructive)
                }
            }
        }
        .navigationTitle("Icons")
    }
}

private struct D2UtilitySection: View {
    @State private var text = ""

    var body: some View {
        List {
            Section("DSDivider") {
                VStack(spacing: 0) {
                    Text("Row").dsText(.bodyRegular).padding(Slowly.Spacing.md)
                    DSDivider()
                    Text("Row").dsText(.bodyRegular).padding(Slowly.Spacing.md)
                }
                .listRowInsets(.init())
            }
            Section("DSTextField") {
                DSTextField("What did you just finish?", text: $text)
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                DSTextField("Pre-filled", text: .constant("Reviewed the quarterly report"))
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("Divider & TextField")
    }
}

private struct D2CheckmarkSection: View {
    @State private var checked = false

    var body: some View {
        List {
            Section("Tap to toggle") {
                HStack {
                    DSCheckmark(checked: checked, size: 28)
                    Text(checked ? "Done" : "Not done").dsText(.bodyRegular)
                }
                .onTapGesture { checked.toggle() }
            }
            Section("Sizes") {
                HStack(spacing: Slowly.Spacing.lg) {
                    VStack {
                        DSCheckmark(checked: true, size: 20)
                        Text("20").dsText(.captionRegular, color: Slowly.Color.textSecondary)
                    }
                    VStack {
                        DSCheckmark(checked: true, size: 24)
                        Text("24").dsText(.captionRegular, color: Slowly.Color.textSecondary)
                    }
                    VStack {
                        DSCheckmark(checked: true, size: 32)
                        Text("32").dsText(.captionRegular, color: Slowly.Color.textSecondary)
                    }
                    VStack {
                        DSCheckmark(checked: false, size: 24)
                        Text("off").dsText(.captionRegular, color: Slowly.Color.textSecondary)
                    }
                }
            }
        }
        .navigationTitle("Checkmark")
    }
}

// MARK: - D3 Composites Gallery

private struct D3AdaptiveHeroSection: View {
    var body: some View {
        ScrollView {
            VStack(spacing: Slowly.Spacing.xxl) {
                VStack(alignment: .leading, spacing: 0) {
                    BigNumeral(value: 7)
                        .padding(.horizontal, Slowly.Spacing.xl)
                    AdaptiveHero(state: .today(
                        date: "Monday, 18 May",
                        headline: "You're on a roll now",
                        subtitle: "Some motivational subtitle goes here maybe in two lines"
                    ))
                }
                Divider()
                AdaptiveHero(state: .reflect(
                    headline: "What a great week",
                    subtitle: "Some motivational subtitle."
                ))
                Divider()
                AdaptiveHero(state: .empty)
            }
            .padding(Slowly.Spacing.xl)
        }
        .background(Slowly.Color.surfaceApp)
        .navigationTitle("Adaptive Hero")
    }
}

private struct D3EntryRowSection: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                TimeOfDaySectionHeader(label: "Afternoon", count: 3)
                    .padding(.horizontal, Slowly.Spacing.xl)
                    .padding(.vertical, Slowly.Spacing.sm)
                EntryRow(text: "Took a 10-min walk", timestamp: "00:33", onMenu: {})
                    .padding(.horizontal, Slowly.Spacing.xl)
                EntryRow(text: "Paid rent", timestamp: "00:33", onMenu: {})
                    .padding(.horizontal, Slowly.Spacing.xl)
                EntryRow(
                    text: "Did my laundry",
                    timestamp: "00:33",
                    isLast: true,
                    isVoiceCaptured: true,
                    onMenu: {}
                )
                .padding(.horizontal, Slowly.Spacing.xl)
            }
        }
        .background(Slowly.Color.surfaceApp)
        .navigationTitle("Entry Row")
    }
}

private struct D3SectionHeaderSection: View {
    var body: some View {
        List {
            TimeOfDaySectionHeader(label: "Morning", count: 1)
            TimeOfDaySectionHeader(label: "Afternoon", count: 6)
            TimeOfDaySectionHeader(label: "Evening", count: 0)
        }
        .navigationTitle("Section Header")
    }
}

private struct D3NavBarSection: View {
    var body: some View {
        List {
            Section("Title only") {
                NavBarPlain(title: "Settings")
                    .listRowInsets(.init())
            }
            Section("With trailing action") {
                NavBarPlain(
                    title: "Search",
                    trailingIcon: "xmark",
                    trailingAction: {},
                    trailingAccessibilityLabel: "Close"
                )
                .listRowInsets(.init())
            }
        }
        .navigationTitle("Nav Bar Plain")
    }
}

private struct D3TabBarSection: View {
    @State private var tab = TabBarMain.Tab.today

    var body: some View {
        ZStack(alignment: .bottom) {
            Slowly.Color.surfaceApp.ignoresSafeArea()
            VStack {
                Text("Selected: \(tab.label)")
                    .font(Slowly.Font.bodyRegular)
                    .foregroundStyle(Slowly.Color.textSecondary)
                Spacer()
            }
            .padding(Slowly.Spacing.xl)

            TabBarMain(selection: $tab, onLog: {})
                .padding(.horizontal, Slowly.Spacing.xl)
                .padding(.bottom, Slowly.Spacing.lg)
        }
        .navigationTitle("Tab Bar Main")
    }
}

private struct D3WeekBarChartSection: View {
    var body: some View {
        List {
            Section("Normal week") {
                WeekBarChart(days: [
                    .init(label: "Wed", count: 2),
                    .init(label: "Thu", count: 5),
                    .init(label: "Fri", count: 1),
                    .init(label: "Sat", count: 4),
                    .init(label: "Sun", count: 0),
                    .init(label: "Mon", count: 3),
                    .init(label: "Today", count: 7, isToday: true),
                ])
                .padding(.vertical, Slowly.Spacing.md)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            Section("All zeros") {
                WeekBarChart(days: (0..<7).map { .init(label: "D\($0)", count: 0) })
                    .padding(.vertical, Slowly.Spacing.md)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .navigationTitle("Week Bar Chart")
    }
}

private struct D3ConfirmationSection: View {
    var body: some View {
        ZStack {
            Slowly.Color.surfaceApp.ignoresSafeArea()
            ConfirmationBlock(
                headline: "Logged!",
                subtext: "One more thing done. Keep going.",
                onDismiss: {}
            )
        }
        .navigationTitle("Confirmation Block")
    }
}

private struct D3VoiceCaptureSection: View {
    @State private var recording = false

    var body: some View {
        ZStack {
            Slowly.Color.surfaceApp.ignoresSafeArea()
            VStack(spacing: Slowly.Spacing.xl) {
                VoiceCaptureButton(isRecording: recording, onTap: { recording.toggle() })
                Text(recording ? "Recording — tap to stop" : "Idle — tap to start")
                    .font(Slowly.Font.footnoteRegular)
                    .foregroundStyle(Slowly.Color.textSecondary)
            }
        }
        .navigationTitle("Voice Capture Button")
    }
}

private struct D3EmptyStateArrowSection: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Slowly.Color.surfaceApp.ignoresSafeArea()
            EmptyStateArrow()
                .padding(Slowly.Spacing.xl)
        }
        .navigationTitle("Empty State Arrow")
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
