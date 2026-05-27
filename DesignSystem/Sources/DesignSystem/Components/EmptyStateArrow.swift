// EmptyStateArrow.swift
// Empty-state hint near the FAB: label + curved arrow pointing to the log FAB.
// Native SwiftUI — no PNG asset needed. Arrow is a hand-tuned bezier curve.
// Figma: 128×107 container, 50% opacity, #6b6b6b stroke, "Add your first "Done"" text.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › node 17:3265 child (EmptyStateArrow, 128×107)

import SwiftUI

/// Subtle arrow + label nudging the user toward the log FAB on an empty Today screen.
/// Rendered at 50% opacity to keep it visually secondary on the empty Today canvas.
public struct EmptyStateArrow: View {

    public init() {}

    public var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Add your first\n\u{201C}Done\u{201D}")
                .font(Slowly.Font.footnoteMedium)
                .foregroundStyle(Slowly.Color.textSecondary)
                .multilineTextAlignment(.trailing)

            CurvedArrow()
                .stroke(
                    Slowly.Color.textSecondary,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
                .frame(width: 70, height: 33)
        }
        .opacity(0.5)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Add your first Done item using the button below")
    }
}

// MARK: - Curved arrow shape

/// Hand-tuned bezier curve approximating the Figma arrow path (70×33 pt bounding box).
/// Starts top-left, curves down-right, ends with an arrowhead pointing right.
private struct CurvedArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()

        let w = rect.width
        let h = rect.height

        // Curve body: starts at leading edge, arcs down to trailing centre
        p.move(to: CGPoint(x: 0, y: h * 0.15))
        p.addCurve(
            to:        CGPoint(x: w * 0.78, y: h * 0.85),
            control1:  CGPoint(x: w * 0.15, y: h * 0),
            control2:  CGPoint(x: w * 0.75, y: h * 0.3)
        )

        // Arrowhead — two short lines diverging from the tip
        let tip = CGPoint(x: w * 0.78, y: h * 0.85)
        p.move(to: tip)
        p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.72))
        p.move(to: tip)
        p.addLine(to: CGPoint(x: w * 0.88, y: h * 0.62))

        return p
    }
}

// MARK: - Preview

#Preview {
    ZStack(alignment: .bottomLeading) {
        Slowly.Color.surfaceApp.ignoresSafeArea()
        EmptyStateArrow()
            .padding(Slowly.Spacing.xl)
    }
}
