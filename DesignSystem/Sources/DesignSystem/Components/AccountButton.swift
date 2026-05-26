// AccountButton.swift
// Circular 44×44 trailing navbar button — person silhouette icon.
// iOS 26: Liquid Glass circle via .glassEffect(.regular, in: .circle) (ADR-0005).
// iOS 18-25: white circle with soft drop shadow.
//
// Figma: node 111:8622 — Slowly MVP, navbar trailing button.
//   • 44×44 pt frame, cornerRadius = circle
//   • DROP_SHADOW { y: 8, blur: 40, color: rgba(0,0,0,0.12) }
//   • Icon: SF Symbol glyph 􀉭 (U+10026D), 18pt, color textPrimary
//     Rendered via Text(verbatim:) because the user specified the literal
//     glyph rather than an SF Symbol name; Text picks it up from the system
//     font (San Francisco) which ships the SF Symbols private-use range.
//   • iOS 26: GLASS { frost: 7, depth: 16, lightAngle: 315°, lightIntensity: 0.8 }
//
// Phase: R4 — D3 composite navbar
// See: design-system/Components.md · design-system/Liquid Glass mapping.md · ADR-0005

import SwiftUI

/// Circular account/avatar button for the Today navbar trailing position.
/// Tapping triggers the provided `action` closure (typically opens Settings sheet).
///
/// iOS 26: Liquid Glass circle (`.glassEffect(.regular, in: .circle)`).
/// iOS 18–25: White circle with a soft drop-shadow (Figma `DROP_SHADOW { blur: 40, y: 8 }`).
///
/// Accessibility: label = "Account", identifier = "Account".
/// See: design-system/Components.md — `AccountButton`
public struct AccountButton: View {

    public let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            icon
                .frame(width: 44, height: 44)
                #if os(iOS)
                .background(buttonBackground)
                #else
                .background(ios18Background)
                #endif
                .clipShape(Circle())
        }
        .accessibilityLabel("Account")
        .accessibilityIdentifier("Account")
    }

    // MARK: - Icon

    private var icon: some View {
        // SF Symbol U+10026D (literal glyph 􀉭) — rendered as text since the
        // system font carries the SF Symbols private-use range. Switch to
        // Image(systemName: "<name>") if/when we want symbol-rendering modes.
        Text(verbatim: "\u{10026D}")
            .font(.system(size: 18, weight: .regular))
            .foregroundStyle(Slowly.Color.textPrimary)
    }

    // MARK: - Backgrounds

    #if os(iOS)
    @ViewBuilder
    private var buttonBackground: some View {
        if #available(iOS 26.0, *) {
            Color.clear
                .glassEffect(.regular, in: .circle)
        } else {
            ios18Background
        }
    }
    #endif

    private var ios18Background: some View {
        Circle()
            .fill(Color.white)
            .shadow(
                color: Color.black.opacity(0.12),
                radius: 20,  // Figma blur:40 → SwiftUI radius ~20
                x: 0,
                y: 8
            )
    }
}

// MARK: - Previews

#Preview("iOS 18 style — Light") {
    AccountButton { }
        .padding()
        .background(Slowly.Color.surfaceApp)
}

#Preview("iOS 18 style — Dark") {
    AccountButton { }
        .padding()
        .background(Color.black)
        .environment(\.colorScheme, .dark)
}
