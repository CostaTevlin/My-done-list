// LogSheet.swift
// Bottom sheet — voice input primary, with a toggle to plain text.
// Voice mode auto-starts on open if permission is granted.
//
// Phase: 4
// See: design-system/Screen specs.md (Log sheet)
//      design-system/Copy bank.md (sheet copy)
//      decisions/0006 — Confetti  ·  decisions/0005 — Liquid Glass

import SwiftUI
import SwiftData
import DesignSystem

// InputMode is internal (not private) so RootTabView and callers can reference it
// without re-declaring the type.
enum InputMode { case voice, text }

// Pulsing ring shown while the mic is active.
private struct PulseRing: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.5

    var body: some View {
        Circle()
            .stroke(Color.tokenCharcoal.opacity(opacity), lineWidth: 1.5)
            .scaleEffect(scale)
            .frame(width: 80, height: 80)
            .onAppear {
                withAnimation(.easeOut(duration: 1.1).repeatForever(autoreverses: false)) {
                    scale = 1.7
                    opacity = 0
                }
            }
    }
}

struct LogSheet: View {

    // MARK: - Init parameters

    /// Voice is the default entry point; text is used when the ghost row
    /// or an edit action opens the sheet directly in keyboard mode.
    let initialMode: InputMode

    /// When set, the sheet is in edit mode: submit updates the item instead
    /// of inserting a new one.
    let editingItem: DoneItem?

    init(initialMode: InputMode = .voice, editingItem: DoneItem? = nil) {
        self.initialMode = initialMode
        self.editingItem = editingItem
    }

    // MARK: - Environment

    @Environment(DoneStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - State

    @State private var text: String = ""
    @State private var mode: InputMode = .voice
    @State private var speech = SpeechRecognizer()
    @FocusState private var textFocused: Bool

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSubmit: Bool { trimmedText.count >= 2 }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            if mode == .voice {
                voiceArea
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            } else {
                textArea
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }

            Spacer()

            Button(action: submit) {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .brandPillStyle()
            .disabled(!canSubmit)
            .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Spacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(reduceMotion ? nil : .spring(duration: 0.3), value: mode)
        .onAppear {
            // Seed text for edit mode before the task delay runs.
            if let item = editingItem {
                text = item.text
            }
            mode = initialMode
        }
        // Auto-start voice once permission arrives (handles already-authorized case)
        .task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard mode == .voice else { return }
            if speech.isAvailable {
                speech.startRecording()
            } else if speech.authorizationResolved {
                // Permission was denied before or during the wait
                switchToText()
            }
            // If authorizationResolved is still false here, the permission dialog is
            // still showing — the onChange handlers below will react when it resolves.
        }
        // Keep text in sync with live transcript
        .onChange(of: speech.transcript) { _, newValue in
            if mode == .voice { text = newValue }
        }
        // Auto-start when permission is granted after the task delay (first-time prompt)
        .onChange(of: speech.isAvailable) { _, available in
            if available && mode == .voice && !speech.isRecording {
                speech.startRecording()
            }
        }
        // Fallback: if permission denied after the task delay, drop into text mode
        .onChange(of: speech.authorizationResolved) { _, _ in
            if !speech.isAvailable && mode == .voice {
                switchToText()
            }
        }
        .onDisappear {
            speech.stopRecording()
            text = ""
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("What's one thing you did?")
                .font(.tokenDisplaySub)
                .kerning(TypographyKerning.displaySub)
                .foregroundStyle(Color.tokenCharcoal)
                .padding(.top, Spacing.xl)

            Text("Even something small. It all counts.")
                .font(.tokenBodySub)
                .foregroundStyle(Color.tokenMid)
                .padding(.bottom, Spacing.xxl)
        }
    }

    // MARK: - Voice area

    private var voiceArea: some View {
        VStack(spacing: Spacing.xl) {
            Spacer(minLength: Spacing.md)

            // Live transcript or status hint
            Text(transcriptDisplayText)
                .font(.tokenBody)
                .kerning(TypographyKerning.body)
                .foregroundStyle(text.isEmpty ? Color.tokenLight : Color.tokenCharcoal)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: text)

            // Mic button with optional pulse ring
            Button(action: toggleRecording) {
                ZStack {
                    if speech.isRecording && !reduceMotion {
                        PulseRing()
                    }

                    Circle()
                        .fill(speech.isRecording ? Color.tokenCharcoal : Color.clear)
                        .overlay { Circle().stroke(Color.tokenCharcoal, lineWidth: 1.5) }
                        .frame(width: 72, height: 72)

                    Image(systemName: speech.isRecording ? "waveform" : "mic")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(speech.isRecording ? Color.tokenWhite : Color.tokenCharcoal)
                        .symbolEffect(.variableColor.iterative, isActive: speech.isRecording)
                }
                .frame(width: 88, height: 88)
            }
            .accessibilityLabel(speech.isRecording ? "Stop recording" : "Start recording")
            .frame(maxWidth: .infinity)

            Button(action: switchToText) {
                Text("Type instead")
                    .font(.tokenBodySub)
                    .foregroundStyle(Color.tokenMid)
            }
            .buttonStyle(.plain)

            Spacer(minLength: Spacing.md)
        }
    }

    private var transcriptDisplayText: String {
        if !text.isEmpty { return text }
        return speech.isRecording ? "Listening…" : "Tap the mic to speak"
    }

    // MARK: - Text area

    private var textArea: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                TextField(
                    "",
                    text: $text,
                    prompt: Text("Took a 10-min walk")
                        .foregroundStyle(Color.tokenLight)
                )
                .font(.tokenBody)
                .kerning(TypographyKerning.body)
                .foregroundStyle(Color.tokenCharcoal)
                .focused($textFocused)
                .submitLabel(.done)
                .onSubmit(submit)
                .padding(.vertical, Spacing.md)
                .accessibilityLabel("What did you do?")

                Rectangle()
                    .fill(textFocused ? Color.tokenCharcoal : Color.tokenBorder)
                    .frame(height: 1)
                    .animation(reduceMotion ? nil : Motion.snappy, value: textFocused)
            }

            Button(action: switchToVoice) {
                Image(systemName: "mic")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.tokenMid)
                    .padding(.leading, Spacing.sm)
                    .padding(.bottom, Spacing.md)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Switch to voice input")
        }
        .task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            textFocused = true
        }
    }

    // MARK: - Actions

    private func toggleRecording() {
        if speech.isRecording {
            speech.stopRecording()
        } else {
            speech.startRecording()
        }
    }

    private func switchToText() {
        speech.stopRecording()
        mode = .text
    }

    private func switchToVoice() {
        textFocused = false
        speech.reset()
        text = ""
        mode = .voice
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            if speech.isAvailable { speech.startRecording() }
        }
    }

    private func submit() {
        guard canSubmit else { return }
        speech.stopRecording()
        if let item = editingItem {
            // Edit mode: update the existing item.
            store.update(item, text: trimmedText)
        } else {
            store.add(text: trimmedText)
            store.fireConfetti()
        }
        HapticEngine.success(reduceMotion: reduceMotion)
        dismiss()
    }
}

#Preview {
    LogSheet()
        .modelContainer(for: DoneItem.self, inMemory: true)
        .environment(DoneStore())
}
