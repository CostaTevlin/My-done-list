// AccountButton.swift
// Circular 44×44 trailing navbar button — Account/avatar entry point.
// Used by TodayScreen as the trailing ToolbarItem; opens the Settings sheet.
//
// Figma: node 111:8622 — Slowly MVP, navbar trailing button.
//   • 44×44 pt frame, fully circular (cornerRadius = 296pt on a 44pt frame)
//   • DROP_SHADOW { y: 8, blur: 40, color: rgba(0,0,0,0.12) }
//   • Icon: SF Symbol `person.crop.circle` (glyph 􀉭 / U+10026D), 22pt,
//     color textPrimary. Rendered via `Image(systemName:)` so iOS resolves
//     the PUA glyph through the SF Symbols renderer rather than the regular
//     text font (which doesn't carry the symbol PUA range — verified
//     empirically: Text(verbatim:) renders the missing-glyph placeholder).
//   • iOS 26: GLASS { frost: 7, depth: 16, lightAngle: 315°, lightIntensity: 0.8 }
//
// Liquid Glass gating (ADR-0005):
//   • iOS 26 (`#available(iOS 26.0, *)`): `.glassEffect(.regular, in: .circle)`
//     applied to a `Color.clear` frame, plus the Figma drop shadow for elevation.
//   • iOS 18–25: white-filled circle + the same drop shadow.
//
// Accessibility: label = "Account", identifier = "Account".
//
// Phase: R4 — D3 composite navbar
// See: design-system/Components.md · design-system/Liquid Glass mapping.md · ADR-0005

import SwiftUI

/// Circular Account/avatar button for the Today navbar trailing position.
/// Tapping triggers the provided `action` closure (typically opens Settings sheet).
public struct AccountButton: View {

    public let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            icon
                .frame(width: 44, height: 44)
                .background(buttonBackground)
                .clipShape(Circle())
                .shadow(
                    color: Color.black.opacity(0.12),
                    radius: 20,           // Figma blur:40 → SwiftUI radius ~20
                    x: 0,
                    y: 8
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Account")
        .accessibilityIdentifier("Account")
    }

    // MARK: - Icon

    private var icon: some View {
        // SF Symbol `person.crop.circle` (PUA glyph 􀉭 / U+10026D).
        // Must be rendered via Image(systemName:) — Text(verbatim:) yields
        // the missing-glyph placeholder on iOS because the system text font
        // doesn't carry the SF Symbols PUA range.
        Image(systemName: "person.crop.circle")
            .font(.system(size: 22, weight: .regular))
            .foregroundStyle(Slowly.Color.textPrimary)
    }

    // MARK: - Background (iOS 18 / 26 split)

    @ViewBuilder
    private var buttonBackground: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            // iOS 26: Liquid Glass material. Apply to clear surface so the
            // system renders the glass effect itself.
            Color.clear.glassEffect(.regular, in: .circle)
        } else {
            ios18Background
        }
        #else
        ios18Background
        #endif
    }

    private var ios18Background: some View {
        Circle().fill(Color.white)
    }
}

// MARK: - Previews

#Preview("On light surface") {
    AccountButton { }
        .padding()
        .background(Slowly.Color.surfaceApp)
}

#Preview("Over busy backdrop") {
    ZStack {
        LinearGradient(
            colors: [.green.opacity(0.4), .blue.opacity(0.3)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        AccountButton { }
    }
    .frame(width: 200, height: 200)
}

#Preview("Dark") {
    AccountButton { }
        .padding()
        .background(Color.black)
        .environment(\.colorScheme, .dark)
}
