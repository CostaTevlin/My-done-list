// LogFABCard.swift
// Compact log input embedded inside LogFABOverlay (iOS 26 only).
// Same voice/text modes as LogSheet but laid out for a floating card.
// Edit mode still routes through LogSheet via the .sheet in RootTabView.
//
// Phase: 4.5
// See: LogSheet.swift (full-height variant used for edit mode + iOS 18-25)

import SwiftUI
import SwiftData
import DesignSystem

@available(iOS 26.0, *)
struct LogFABCard: View {
    let onDismiss: () -> Void

    @Environment(DoneStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var text: String = ""
    @State private var mode: InputMode = .voice
    @State private var speech = SpeechRecognizer()
    @FocusState private var textFocused: Bool

    private var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSubmit: Bool { trimmedText.count >= 2 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.md)

            if mode == .voice {
                voiceContent
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            } else {
                textContent
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.card))
        .animation(reduceMotion ? nil : .spring(duration: 0.3), value: mode)
        .task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard mode == .voice else { return }
            if speech.isAvailable {
                speech.startRecording()
            } else if speech.authorizationResolved {
                mode = .text
            }
        }
        .onChange(of: speech.transcript) { _, v in if mode == .voice { text = v } }
        .onChange(of: speech.isAvailable) { _, available in
            if available && mode == .voice && !speech.isRecording { speech.startRecording() }
        }
        .onChange(of: speech.authorizationResolved) { _, _ in
            if !speech.isAvailable && mode == .voice { mode = .text }
        }
        .onDisappear {
            speech.stopRecording()
            text = ""
        }
    }

    // MARK: - Header

    private var cardHeader: some View {
        HStack {
            Text(CopyBank.logSheetTitle)
                .font(.bodyText)
                .fontWeight(.semibold)
                .foregroundStyle(Color.tokenInk)

            Spacer()

            modeTogglePill

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.tokenSlate)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
            .padding(.leading, Spacing.sm)
        }
    }

    private var modeTogglePill: some View {
        Button(action: toggleMode) {
            Text(mode == .voice ? CopyBank.voiceModeToggleToText : CopyBank.voiceModeToggleToVoice)
                .font(.bodySub)
                .foregroundStyle(Color.tokenInk)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs + 2)
                .background(Capsule().fill(Color.tokenMist))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode == .voice ? "Switch to text input" : "Switch to voice input")
    }

    // MARK: - Voice content

    private var voiceContent: some View {
        VStack(spacing: Spacing.lg) {
            Group {
                if text.isEmpty {
                    Text(CopyBank.voiceTrySayingExample)
                        .font(.bodyText)
                        .foregroundStyle(Color.tokenSlate)
                        .multilineTextAlignment(.center)
                } else {
                    Text(text)
                        .font(.bodyText)
                        .foregroundStyle(Color.tokenInk)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.xxl)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: text.isEmpty)

            HStack(spacing: 0) {
                Button(action: restartRecording) {
                    ZStack {
                        Circle().fill(Color.tokenMist).frame(width: 44, height: 44)
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.tokenSlate)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Restart recording")
                .frame(maxWidth: .infinity)

                PulseRing(isPulsing: speech.isRecording)
                    .frame(maxWidth: .infinity)

                Button(action: submit) {
                    ZStack {
                        Circle()
                            .fill(canSubmit ? Color.tokenInk : Color.tokenMist)
                            .frame(width: 44, height: 44)
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(canSubmit ? Color.tokenSurface : Color.tokenSlate)
                    }
                }
                .disabled(!canSubmit)
                .buttonStyle(.plain)
                .accessibilityLabel("Confirm")
                .accessibilityHint(canSubmit ? "" : "Speak something first")
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.bottom, Spacing.xl)
        }
    }

    // MARK: - Text content

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                TextField(
                    "",
                    text: $text,
                    prompt: Text("Took a 10-min walk")
                        .foregroundStyle(Color.tokenSlate.opacity(0.6))
                )
                .font(.bodyText)
                .foregroundStyle(Color.tokenInk)
                .focused($textFocused)
                .submitLabel(.done)
                .onSubmit(submit)
                .padding(.vertical, Spacing.md)

                Rectangle()
                    .fill(textFocused ? Color.tokenInk : Color.tokenMist)
                    .frame(height: 1)
                    .animation(reduceMotion ? nil : Motion.snappy, value: textFocused)
            }
            .padding(.horizontal, Spacing.xxl)
            .task {
                try? await Task.sleep(nanoseconds: 50_000_000)
                textFocused = true
            }

            Button(action: submit) {
                Text("Done").frame(maxWidth: .infinity)
            }
            .brandPillStyle()
            .disabled(!canSubmit)
            .padding(.horizontal, Spacing.xxl)
            .padding(.vertical, Spacing.lg)
        }
    }

    // MARK: - Actions

    private func toggleMode() {
        if mode == .voice {
            speech.stopRecording()
            mode = .text
        } else {
            textFocused = false
            speech.reset()
            text = ""
            mode = .voice
            Task {
                try? await Task.sleep(nanoseconds: 200_000_000)
                if speech.isAvailable { speech.startRecording() }
            }
        }
    }

    private func restartRecording() {
        speech.reset()
        text = ""
        if speech.isAvailable { speech.startRecording() }
    }

    private func submit() {
        guard canSubmit else { return }
        speech.stopRecording()
        store.add(text: trimmedText)
        store.fireConfetti()
        HapticEngine.success(reduceMotion: reduceMotion)
        onDismiss()
    }
}
