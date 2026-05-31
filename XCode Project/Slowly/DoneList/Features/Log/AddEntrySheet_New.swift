// AddEntrySheet_New.swift
// Add-entry sheet — R4 rebuild. Three internal states: listening / captured / textMode.
//
// State machine:
//   .listening  — SpeechRecognizer recording; "Try saying" prompt shown.
//   .captured   — Transcript arrived (≥2 chars); recording stopped; large transcript
//                 displayed for review. User can confirm, edit, or restart.
//   .textMode   — DSTextField focused; voice is off. Entered via "Edit" from captured,
//                 "Type instead" from listening, or when voice is unavailable.
//
// Edit mode: when editingItem is non-nil, opens in .textMode with item text pre-filled.
// Voice unavailable: falls through to .textMode automatically.
//
// Phase: R4
// See: design-system/Screen specs.md (Log sheet)  ·  ADR-0010 (voice-first)

import SwiftUI
import SwiftData
import DesignSystem

struct AddEntrySheet_New: View {

    // MARK: - Init

    let editingItem: DoneItem?

    init(editingItem: DoneItem? = nil) {
        self.editingItem = editingItem
        // Initialise state from editingItem here so the values are set before
        // the first render — avoids a onAppear vs .task ordering race (M3).
        let isEditing = editingItem != nil
        self._sheetState = State(initialValue: isEditing ? .textMode : .listening)
        self._text = State(initialValue: editingItem?.text ?? "")
    }

    // MARK: - Environment

    @Environment(DoneStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Internal state machine

    private enum SheetState { case listening, captured, textMode }

    // Icon-button geometry — named here instead of inline literals (coding.md).
    private enum Icon {
        static let outerSmall: CGFloat = 32   // xmark / dismiss circle
        static let outerLarge: CGFloat = 44   // restart / confirm circles
        static let sizeSmall: CGFloat  = 13   // xmark glyph
        static let sizeMedium: CGFloat = 16   // arrow.counterclockwise / checkmark glyph
    }

    @State private var sheetState: SheetState = .listening
    @State private var text: String = ""
    // Explicit voice-ness flag: set to true only when a transcript arrives while
    // listening; cleared on any manual mode switch or restart. Safer than
    // inferring from sheetState at submit time (M1).
    @State private var enteredViaVoice = false
    @State private var speech = SpeechRecognizer()
    @FocusState private var textFocused: Bool

    private var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSubmit: Bool { trimmedText.count >= 2 }
    private var isEditing: Bool { editingItem != nil }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sheetHeader
                .padding(.horizontal, Slowly.Spacing.xl)
                .padding(.top, Slowly.Spacing.lg)
                .padding(.bottom, Slowly.Spacing.md)

            Group {
                switch sheetState {
                case .listening: listeningArea
                case .captured:  capturedArea
                case .textMode:  textModeArea
                }
            }
            .animation(reduceMotion ? nil : .spring(duration: 0.3, bounce: 0.05), value: sheetState)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .task {
            guard sheetState == .listening else { return }
            try? await Task.sleep(for: .milliseconds(350))
            if speech.isAvailable {
                speech.startRecording()
            } else if speech.authorizationResolved {
                // Permission was denied; fall through to text mode.
                sheetState = .textMode
            }
            // If neither branch fires: isAvailable == false && authorizationResolved == false
            // means the OS permission prompt is still pending. The onChange(of:
            // speech.authorizationResolved) handler below covers that recovery path (m8).
        }
        .onChange(of: speech.transcript) { _, newValue in
            guard sheetState == .listening, newValue.count >= 2 else { return }
            text = newValue
            enteredViaVoice = true   // M1: track voice provenance explicitly
            speech.stopRecording()
            withAnimation(reduceMotion ? nil : .spring(duration: 0.35, bounce: 0.05)) {
                sheetState = .captured
            }
        }
        .onChange(of: speech.isAvailable) { _, available in
            if available, sheetState == .listening, !speech.isRecording {
                speech.startRecording()
            }
        }
        .onChange(of: speech.authorizationResolved) { _, _ in
            if !speech.isAvailable, sheetState == .listening {
                sheetState = .textMode
            }
        }
        .onDisappear {
            speech.stopRecording()
            text = ""
            enteredViaVoice = false
        }
    }

    // MARK: - Header

    private var sheetHeader: some View {
        HStack(alignment: .center, spacing: Slowly.Spacing.sm) {
            // Close
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Slowly.Color.borderDefault)
                        .frame(width: Icon.outerSmall, height: Icon.outerSmall)
                    Image(systemName: "xmark")
                        .font(.system(size: Icon.sizeSmall, weight: .semibold))
                        .foregroundStyle(Slowly.Color.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
            .frame(minWidth: 44, minHeight: 44)

            Spacer()

            Text(isEditing ? "Edit entry" : CopyBank.logSheetTitle)
                .font(Slowly.Font.bodyMedium)
                .foregroundStyle(Slowly.Color.textPrimary)

            Spacer()

            // Right button — varies by state; placeholder keeps title centred
            if isEditing {
                Color.clear.frame(width: 32, height: 32)
            } else {
                headerTrailingButton
            }
        }
    }

    @ViewBuilder
    private var headerTrailingButton: some View {
        switch sheetState {
        case .listening:
            Button("Type instead") { switchToText() }
                .font(Slowly.Font.footnoteRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Switch to text input")

        case .captured:
            Button("Edit") { switchToText() }
                .font(Slowly.Font.footnoteRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Edit the captured text")

        case .textMode:
            Button("Use voice") { switchToVoice() }
                .font(Slowly.Font.footnoteRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Switch to voice input")
        }
    }

    // MARK: - Listening area

    private var listeningArea: some View {
        VStack(spacing: 0) {
            // Prompt or live transcript
            Group {
                if text.isEmpty {
                    trySayingPrompt
                } else {
                    liveTranscript
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Slowly.Spacing.xl)

            Spacer(minLength: Slowly.Spacing.xl)

            VStack(spacing: Slowly.Spacing.lg) {
                listeningCaption
                listeningDock
            }
            .padding(.horizontal, Slowly.Spacing.xl)
            .padding(.bottom, Slowly.Spacing.xl)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    private var trySayingPrompt: some View {
        VStack(spacing: Slowly.Spacing.sm) {
            Spacer(minLength: Slowly.Spacing.xxxl)
            Text(CopyBank.voiceTrySayingLabel)
                .font(Slowly.Font.footnoteRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
            Text(CopyBank.voiceTrySayingExample)
                .font(Slowly.Font.bodyRegular)
                .foregroundStyle(Slowly.Color.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var liveTranscript: some View {
        VStack {
            Spacer(minLength: Slowly.Spacing.xxxl)
            Text(text)
                .font(Slowly.Font.bodyRegular)
                .foregroundStyle(Slowly.Color.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var listeningCaption: some View {
        VStack(spacing: 4) {
            Text(CopyBank.voiceListeningCaption)
                .font(Slowly.Font.bodyRegular)
                .fontWeight(.bold)
                .foregroundStyle(Slowly.Color.textPrimary)
            Text(CopyBank.voiceListeningSubcaption)
                .font(Slowly.Font.footnoteRegular)
                .foregroundStyle(Slowly.Color.textSecondary)
        }
        .multilineTextAlignment(.center)
    }

    private var listeningDock: some View {
        HStack(spacing: 0) {
            // Restart
            Button(action: restartRecording) {
                ZStack {
                    Circle()
                        .fill(Slowly.Color.borderDefault)
                        .frame(width: Icon.outerLarge, height: Icon.outerLarge)
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: Icon.sizeMedium, weight: .medium))
                        .foregroundStyle(Slowly.Color.textSecondary)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Restart recording")
            .frame(maxWidth: .infinity)

            // Pulse ring
            PulseRing(isPulsing: speech.isRecording)
                .frame(maxWidth: .infinity)

            // Disabled confirm (becomes enabled in captured state)
            Circle()
                .fill(Slowly.Color.borderDefault)
                .frame(width: Icon.outerLarge, height: Icon.outerLarge)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: Icon.sizeMedium, weight: .semibold))
                        .foregroundStyle(Slowly.Color.textSecondary)
                )
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Captured area

    private var capturedArea: some View {
        VStack(spacing: 0) {
            // Transcript — large, prominent
            VStack {
                Spacer(minLength: Slowly.Spacing.xxxl)
                Text(text)
                    .font(Slowly.Font.title1Light)
                    .foregroundStyle(Slowly.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Slowly.Spacing.xl)
                    .accessibilityLabel("Captured: \(text)")
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: Slowly.Spacing.xl)

            // Actions
            VStack(spacing: Slowly.Spacing.sm) {
                // Primary — confirm and log
                Button(action: submit) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DSButtonStyle(.primary))
                .disabled(!canSubmit)
                .padding(.horizontal, Slowly.Spacing.xl)

                // Secondary — restart recording
                Button(action: restartRecording) {
                    Text("Try again")
                }
                .buttonStyle(DSButtonStyle(.secondary))
                .accessibilityLabel("Discard and restart voice capture")
            }
            .padding(.bottom, Slowly.Spacing.xl)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    // MARK: - Text mode area

    private var textModeArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSTextField(
                isEditing
                    ? "Update what you did\u{2026}"
                    : "What did you just do\u{2026}",
                text: $text
            )
            .focused($textFocused)
            .submitLabel(.done)
            .onSubmit(submit)
            .padding(.horizontal, Slowly.Spacing.xl)
            .task {
                try? await Task.sleep(for: .milliseconds(50))
                textFocused = true
            }

            Spacer()

            Button(action: submit) {
                Text(isEditing ? "Save" : "Done")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DSButtonStyle(.primary))
            .disabled(!canSubmit)
            .padding(.horizontal, Slowly.Spacing.xl)
            .padding(.bottom, Slowly.Spacing.xl)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }

    // MARK: - Actions

    private func switchToText() {
        enteredViaVoice = false   // M1: switching to text resets voice provenance
        speech.stopRecording()
        sheetState = .textMode
    }

    private func switchToVoice() {
        textFocused = false
        enteredViaVoice = false
        speech.reset()
        text = ""
        sheetState = .listening
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            if speech.isAvailable { speech.startRecording() }
        }
    }

    private func restartRecording() {
        enteredViaVoice = false   // discarding the transcript resets provenance
        speech.reset()
        text = ""
        sheetState = .listening
        if speech.isAvailable { speech.startRecording() }
    }

    private func submit() {
        guard canSubmit else { return }
        // Capture all values before dismiss() — onDisappear clears text (M2).
        let savedText   = trimmedText
        let savedSource = enteredViaVoice ? EntrySource.voice : .text
        speech.stopRecording()
        if let item = editingItem {
            store.update(item, text: savedText)
        } else {
            store.add(text: savedText, source: savedSource)
            store.fireConfetti()
        }
        HapticEngine.success(reduceMotion: reduceMotion)
        dismiss()
    }
}

// MARK: - Preview

#Preview("Listening") {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            AddEntrySheet_New()
                .modelContainer(for: DoneItem.self, inMemory: true)
                .environment(DoneStore())
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Slowly.Radius.sheet)
        }
}

#Preview("Edit existing") {
    let item = DoneItem(text: "Finished the deck", time: "14:30", date: DoneStore.todayKey())
    Color.clear
        .sheet(isPresented: .constant(true)) {
            AddEntrySheet_New(editingItem: item)
                .modelContainer(for: DoneItem.self, inMemory: true)
                .environment(DoneStore())
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Slowly.Radius.sheet)
        }
}
