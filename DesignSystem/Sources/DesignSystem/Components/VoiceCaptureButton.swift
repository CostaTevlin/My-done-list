// VoiceCaptureButton.swift
// FAB-scale voice capture trigger — mic circle + PulseRing in recording state.
// This is the button surface only; the full LogSheet is wired at the app feature layer.
// Phase: D3 · R3 Composites
// Source of truth: Figma Slowly-MVP › D0 Experience › log FAB / voice button

import SwiftUI

/// Circular mic button that wraps `PulseRing` when recording.
/// 60pt target, `textPrimary`-fill, `textPrimaryWhite` icon.
public struct VoiceCaptureButton: View {

    public let isRecording: Bool
    public let onTap: () -> Void

    public init(isRecording: Bool, onTap: @escaping () -> Void) {
        self.isRecording = isRecording
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            ZStack {
                if isRecording {
                    PulseRing(isPulsing: true)
                }

                Image(systemName: "mic.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Slowly.Color.textPrimaryWhite)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Slowly.Color.textPrimary)
                            .shadow(
                                color: Slowly.Color.textPrimary.opacity(0.18),
                                radius: 12, y: 4
                            )
                    )
            }
        }
        .accessibilityLabel("Log something you did")
        .accessibilityHint("Opens voice capture")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview

#Preview("Idle") {
    ZStack {
        Slowly.Color.surfaceApp.ignoresSafeArea()
        VoiceCaptureButton(isRecording: false, onTap: {})
    }
}

#Preview("Recording") {
    ZStack {
        Slowly.Color.surfaceApp.ignoresSafeArea()
        VoiceCaptureButton(isRecording: true, onTap: {})
    }
}
