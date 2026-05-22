// DSText.swift
// Slowly text-style modifier. Bundles Slowly.Font.* + foreground color in one call site.
// Numeric styles (bigNumeral, captionRegular, footnoteMedium) auto-apply .monospacedDigit().
// Usage: Text("Ag").dsText(.bodyRegular)
//        Text("7").dsText(.bigNumeral)
//        Text("note").dsText(.footnoteRegular, color: Slowly.Color.textSecondary)
// Phase: 4.5 · D2 primitives
// Source of truth: Figma Slowly-MVP › Typography tokens (nodes 17:2463 + 17:3265)

import SwiftUI

public enum DSTextStyle: CaseIterable {
    case bigNumeral
    case titleDisplay
    case title1Light
    case title2Light
    case headlineRegular
    case bodyRegular
    case bodyMedium
    case footnoteRegular
    case footnoteMedium
    case captionRegular
    case captionBold

    public var font: SwiftUI.Font {
        switch self {
        case .bigNumeral:      Slowly.Font.bigNumeral.monospacedDigit()
        case .titleDisplay:    Slowly.Font.titleDisplay
        case .title1Light:     Slowly.Font.title1Light
        case .title2Light:     Slowly.Font.title2Light
        case .headlineRegular: Slowly.Font.headlineRegular
        case .bodyRegular:     Slowly.Font.bodyRegular
        case .bodyMedium:      Slowly.Font.bodyMedium
        case .footnoteRegular: Slowly.Font.footnoteRegular
        case .footnoteMedium:  Slowly.Font.footnoteMedium.monospacedDigit()
        case .captionRegular:  Slowly.Font.captionRegular.monospacedDigit()
        case .captionBold:     Slowly.Font.captionBold
        }
    }
}

public struct DSTextModifier: ViewModifier {
    let style: DSTextStyle
    let color: SwiftUI.Color

    public func body(content: Content) -> some View {
        content
            .font(style.font)
            .foregroundStyle(color)
    }
}

public extension View {
    func dsText(_ style: DSTextStyle, color: SwiftUI.Color = Slowly.Color.textPrimary) -> some View {
        modifier(DSTextModifier(style: style, color: color))
    }
}

#Preview("DSText") {
    List {
        Group {
            Text("7").dsText(.bigNumeral)
            Text("Title Display 60").dsText(.titleDisplay)
            Text("Title 1 Light 40").dsText(.title1Light)
            Text("Title 2 Light 30").dsText(.title2Light)
        }
        Group {
            Text("Headline Regular 18").dsText(.headlineRegular)
            Text("Body Regular 16").dsText(.bodyRegular)
            Text("Body Medium 16").dsText(.bodyMedium)
            Text("Footnote Regular 13").dsText(.footnoteRegular)
            Text("Footnote Medium 13").dsText(.footnoteMedium)
            Text("Caption Regular 11").dsText(.captionRegular)
            Text("Caption Bold 11").dsText(.captionBold)
        }
        Group {
            Text("Secondary color").dsText(.bodyRegular, color: Slowly.Color.textSecondary)
            Text("Accent color").dsText(.bodyMedium, color: Slowly.Color.accentPrimary)
        }
    }
    .background(Slowly.Color.surfaceApp)
}
