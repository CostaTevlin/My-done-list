// EmptyStateSproutImage.swift
// Watercolor sprout-in-dirt illustration for the Today empty state.
// Wraps the `emptyStateSprout` asset (PNG @1x/@2x/@3x) so feature code
// doesn't need access to the DesignSystem bundle directly.
//
// Source: Figma `112:9882` (Slowly MVP › empty-state). Exported as PNG via
// the Figma Desktop Bridge plugin and bundled into the design-system asset
// catalog.
//
// Phase: R4 — D3 composite empty state
// See: design-system/Screen specs.md (Today · empty)

import SwiftUI

/// 1:1 ratio watercolor sprout illustration. Caller sets the frame; the
/// image scales with `aspectRatio(contentMode: .fit)`.
public struct EmptyStateSproutImage: View {

    public init() {}

    public var body: some View {
        Image("emptyStateSprout", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibilityHidden(true)  // decorative — companion text carries the meaning
    }
}

#Preview("140pt") {
    EmptyStateSproutImage()
        .frame(width: 140, height: 140)
        .padding()
}

#Preview("Larger on dark background") {
    EmptyStateSproutImage()
        .frame(width: 220, height: 220)
        .padding()
        .background(Color.black)
}
