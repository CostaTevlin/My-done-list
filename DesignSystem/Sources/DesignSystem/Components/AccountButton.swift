// AccountButton.swift
// Circular 44×44 trailing navbar button — Account/avatar entry point.
// Used by TodayScreen as the trailing ToolbarItem; opens the Settings sheet.
//
// Figma: node 111:8622 (and 112:9873) — Slowly MVP, navbar trailing button.
//   • 44×44 pt frame, fully circular (cornerRadius = circle)
//   • DROP_SHADOW { y: 8, blur: 40, color: rgba(0,0,0,0.12) }
//   • Icon: SF Symbol `person.crop.circle` (glyph 􀉭 / U+10026D), 22pt,
//     color textPrimary. Rendered via `Image(systemName:)` so iOS resolves
//     the PUA glyph through the SF Symbols renderer rather than the regular
//     text font (which doesn't carry the symbol PUA range).
//   • iOS 26: GLASS { frost: 7, depth: 16, lightAngle: 315°, lightIntensity: 0.8 }
//
// Liquid Glass gating (ADR-0005):
//   • iOS 26 (`#available(iOS 26.0, *)`): provide only the icon — the iOS 26
//     toolbar wraps the button content in its own Liquid Glass treatment.
//     `.buttonBorderShape(.circle)` hints the system to render a circular
//     glass capsule rather than the default rounded-rectangle (which was
//     observed empirically with our previous custom-shape approach).
//   • iOS 18–25: custom white-filled circle with the Figma drop shadow.
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
        #if os(iOS)
        if #available(iOS 26.0, *) {
            iOS26Button
        } else {
            iOS18Button
        }
        #else
        iOS18Button
        #endif
    }

    // MARK: - iOS 26 path

    #if os(iOS)
    @available(iOS 26.0, *)
    private var iOS26Button: some View {
        // The iOS 26 toolbar wraps Button content in its own Liquid Glass
        // capsule. We hand it just the SF Symbol and request a circular
        // border shape so the system renders a circle, not the default
        // rounded-rectangle. The system also supplies the elevation/shadow.
        Button(action: action) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(Slowly.Color.textPrimary)
        }
        .buttonBorderShape(.circle)
        .accessibilityLabel("Account")
        .accessibilityIdentifier("Account")
    }
    #endif

    // MARK: - iOS 18 fallback

    private var iOS18Button: some View {
        Button(action: action) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(Slowly.Color.textPrimary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white))
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
