// LogSheet.swift
// Capture sheet — voice-first (ADR-0010). Two modes: .voice (default) and .text.
// Edit mode: when editingItem is set, opens in .text, hides mode toggle.
//
// Phase: 4.5 (ADR-0010, ADR-0011)
// See: design-system/Screen specs.md (Log sheet)
//      design-system/Copy bank.md
//      decisions/0005 — Liquid Glass · decisions/0006 — Confetti · decisions/0010

import SwiftUI
import SwiftData
import DesignSystem

enum InputMode { case voice, text }

struct LogSheet: View {

    // MARK: - Init

    let initialMode: InputMode
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

    private var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSubmit: Bool { trimmedText.count >= 2 }
    private var isEditing: Bool { editingItem != nil }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sheetHeader
                .padding(.horizontal, Spacing.xxl)
                .padding(.top, Spacing.xl)
                .padding(.bottom, Spacing.lg)

            if mode == .voice {
                voiceArea
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            } else {
                textArea
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(reduceMotion ? nil : .spring(duration: 0.3), value: mode)
        .onAppear {
            if let item = editingItem { text = item.text }
            mode = initialMode
        }
        .task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard mode == .voice else { return }
            if speech.isAvailable {
                speech.startRecording()
            } else if speech.authorizationResolved {
                switchToText()
            }
        }
        .onChange(of: speech.transcript) { _, newValue in
            if mode == .voice { text = newValue }
        }
        .onChange(of: speech.isAvailable) { _, available in
            if available && mode == .voice && !speech.isRecording {
                speech.startRecording()
            }
        }
        .onChange(of: speech.authorizationResolved) { _, _ in
            if !speech.isAvailable && mode == .voice { switchToText() }
        }
        .onDisappear {
            speech.stopRecording()
            text = ""
        }
    }

    // MARK: - Header

    private var sheetHeader: some View {
        HStack(alignment: .center, spacing: Spacing.sm) {
            // X close
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.borderDefault)
                        .frame(width: 32, height: 32)
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
            .frame(minWidth: 44, minHeight: 44)

            Spacer()

            Text(CopyBank.logSheetTitle)
                .font(.bodyText)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            // Mode toggle pill — hidden entirely in edit mode
            if isEditing {
                // Matching width placeholder so the title stays centered
                Color.clear
                    .frame(width: 32, height: 32)
            } else {
                modeTogglePill
            }
        }
    }

    private var modeTogglePill: some View {
        Button(action: toggleMode) {
            Text(mode == .voice ? CopyBank.voiceModeToggleToText : CopyBank.voiceModeToggleToVoice)
                .font(.bodySub)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs + 2)
                .background(
                    Capsule().fill(Color.borderDefault)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode == .voice
            ? "Switch to text input"
            : "Switch to voice input")
    }

    // MARK: - Voice area

    private var voiceArea: some View {
        VStack(spacing: 0) {
            // Content: "Try saying" prompt (hidden once transcript arrives)
            Group {
                if text.isEmpty {
                    trySayingPrompt
                } else {
                    transcriptDisplay
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.xxl)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: text.isEmpty)

            Spacer(minLength: Spacing.xl)

            // Listening surface: caption + bottom dock
            VStack(spacing: Spacing.lg) {
                listeningCaption
                voiceBottomDock
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var trySayingPrompt: some View {
        VStack(spacing: Spacing.sm) {
            Spacer(minLength: Spacing.xxxl)

            Text(CopyBank.voiceTrySayingLabel)
                .font(.bodySub)
                .foregroundStyle(Color.textSecondary)

            Text(CopyBank.voiceTrySayingExample)
                .font(.bodyText)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var transcriptDisplay: some View {
        VStack {
            Spacer(minLength: Spacing.xxxl)
            Text(text)
                .font(.bodyText)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var listeningCaption: some View {
        VStack(spacing: 4) {
            Text(CopyBank.voiceListeningCaption)
                .font(.bodyText)
                .fontWeight(.bold)
                .foregroundStyle(Color.textPrimary)
            Text(CopyBank.voiceListeningSubcaption)
                .font(.bodySub)
                .foregroundStyle(Color.textSecondary)
        }
        .multilineTextAlignment(.center)
    }

    private var voiceBottomDock: some View {
        HStack(spacing: 0) {
            // Restart
            Button(action: restartRecording) {
                ZStack {
                    Circle()
                        .fill(Color.borderDefault)
                        .frame(width: 44, height: 44)
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Restart recording")
            .frame(maxWidth: .infinity)

            // PulseRing (center)
            PulseRing(isPulsing: speech.isRecording)
                .frame(maxWidth: .infinity)

            // Confirm checkmark — disabled until transcript has content
            Button(action: submit) {
                ZStack {
                    Circle()
                        .fill(canSubmit ? Color.textPrimary : Color.borderDefault)
                        .frame(width: 44, height: 44)
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canSubmit ? Color.surfaceApp : Color.textSecondary)
                }
            }
            .disabled(!canSubmit)
            .buttonStyle(.plain)
            .accessibilityLabel("Confirm")
            .accessibilityHint(canSubmit ? "" : "Speak something first")
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Text area

    private var textArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text("Took a 10-min walk")
                            .foregroundStyle(Color.textSecondary.opacity(0.6))
                    )
                    .font(.bodyText)
                    .foregroundStyle(Color.textPrimary)
                    .focused($textFocused)
                    .submitLabel(.done)
                    .onSubmit(submit)
                    .padding(.vertical, Spacing.md)
                    .accessibilityLabel("What did you do?")

                    Rectangle()
                        .fill(textFocused ? Color.textPrimary : Color.borderDefault)
                        .frame(height: 1)
                        .animation(reduceMotion ? nil : Motion.snappy, value: textFocused)
                }
            }
            .padding(.horizontal, Spacing.xxl)
            .task {
                try? await Task.sleep(nanoseconds: 50_000_000)
                textFocused = true
            }

            Spacer()

            Button(action: submit) {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .brandPillStyle()
            .disabled(!canSubmit)
            .padding(.horizontal, Spacing.xxl)
            .padding(.bottom, Spacing.xl)
        }
    }

    // MARK: - Actions

    private func toggleMode() {
        if mode == .voice {
            switchToText()
        } else {
            switchToVoice()
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

    private func restartRecording() {
        speech.reset()
        text = ""
        if speech.isAvailable { speech.startRecording() }
    }

    private func submit() {
        guard canSubmit else { return }
        speech.stopRecording()
        if let item = editingItem {
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
