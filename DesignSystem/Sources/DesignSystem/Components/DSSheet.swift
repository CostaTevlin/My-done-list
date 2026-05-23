// DSSheet.swift
// Bottom sheet surface wrapper — glass on iOS 26, opaque on iOS 18.
// Callers use: .sheet { DSSheet { content } }
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › D0 Experience › log sheet / modal surface

import SwiftUI

/// Bottom sheet surface with a drag handle and state-aware background.
/// iOS 26: `.thinMaterial` presentation background (glass).
/// iOS 18: `surfaceApp` opaque background.
///
/// Usage:
/// ```swift
/// .sheet(isPresented: $showSheet) {
///     DSSheet {
///         MyContent()
///     }
/// }
/// ```
public struct DSSheet<Content: View>: View {

    public let detents: Set<PresentationDetent>
    private let content: Content

    public init(
        detents: Set<PresentationDetent> = [.large],
        @ViewBuilder content: () -> Content
    ) {
        self.detents = detents
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            handle
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .presentationDetents(detents)
        .presentationDragIndicator(.hidden) // we draw our own handle
        .modifier(SheetBackgroundModifier())
    }

    private var handle: some View {
        Capsule(style: .continuous)
            .fill(Slowly.Color.borderDefault)
            .frame(width: 36, height: 4)
            .padding(.top, Slowly.Spacing.sm)
            .padding(.bottom, Slowly.Spacing.xs)
    }
}

// MARK: - Background modifier

private struct SheetBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .presentationBackground(.thinMaterial)
        } else {
            content
                .presentationBackground(Slowly.Color.surfaceApp)
        }
    }
}

// MARK: - Preview

#Preview("Sheet surface") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            DSSheet(detents: [.medium, .large]) {
                VStack(alignment: .leading, spacing: Slowly.Spacing.lg) {
                    Text("Sheet content")
                        .font(Slowly.Font.headlineRegular)
                        .foregroundStyle(Slowly.Color.textPrimary)
                    Text("Secondary text or form fields go here.")
                        .font(Slowly.Font.bodyRegular)
                        .foregroundStyle(Slowly.Color.textSecondary)
                }
                .padding(Slowly.Spacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
}
