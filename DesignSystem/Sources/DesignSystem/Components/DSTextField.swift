// DSTextField.swift
// Slowly-branded single-line text field: ghost-cream background, borderDefault stroke,
// card-radius corners, bodyRegular font.
// No focus-state styling in D2 — added in R4 when assembled into screen flows.
// Phase: 4.5 · D2 primitives
// Source of truth: Figma Slowly-MVP › "_Text Field Background" + "Text Field" components

import SwiftUI

public struct DSTextField: View {
    private let placeholder: String
    @Binding private var text: String

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        TextField(placeholder, text: $text)
            .font(Slowly.Font.bodyRegular)
            .foregroundStyle(Slowly.Color.textPrimary)
            .padding(.vertical, Slowly.Spacing.sm)
            .padding(.horizontal, Slowly.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Slowly.Radius.card)
                    .fill(Slowly.Color.surfaceGhost)
                    .overlay(
                        RoundedRectangle(cornerRadius: Slowly.Radius.card)
                            .strokeBorder(Slowly.Color.borderDefault, lineWidth: 1)
                    )
            )
    }
}

#Preview("DSTextField") {
    @Previewable @State var text = ""

    VStack(spacing: Slowly.Spacing.lg) {
        DSTextField("What did you just finish?", text: $text)
        DSTextField("Pre-filled example", text: .constant("Reviewed the quarterly report"))
    }
    .padding(Slowly.Spacing.xl)
    .background(Slowly.Color.surfaceApp)
}
