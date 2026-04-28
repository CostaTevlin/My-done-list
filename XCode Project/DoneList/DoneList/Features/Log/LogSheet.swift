// LogSheet.swift
// Bottom sheet with autofocused TextField + "Done" button.
// On submit: insert item · dismiss · gentle haptic · trigger confetti variant.
//
// Phase: 4
// See: design-system/Screen specs.md (Log sheet)
//      design-system/Copy bank.md (sheet copy)
//      decisions/0006 — Confetti  ·  decisions/0005 — Liquid Glass

import SwiftUI
import SwiftData
import DesignSystem

struct LogSheet: View {

    // MARK: - Environment

    @Environment(DoneStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Local state

    @State private var text: String = ""
    @FocusState private var focused: Bool

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Mirrors PWA gate: must have at least 2 non-whitespace characters.
    private var canSubmit: Bool {
        trimmedText.count >= 2
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("What's one thing you did?")
                .font(.tokenDisplaySub)
                .kerning(TypographyKerning.displaySub)
                .foregroundStyle(Color.tokenCharcoal)
                .padding(.top, Spacing.xl)

            Text("Even something small. It all counts.")
                .font(.tokenBodySub)
                .foregroundStyle(Color.tokenMid)
                .padding(.top, Spacing.sm)

            // Single-line text field with a 1pt underline that darkens on focus.
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
                .focused($focused)
                .submitLabel(.done)
                .onSubmit(submit)
                .padding(.vertical, Spacing.md)
                .accessibilityLabel("What did you do?")

                Rectangle()
                    .fill(focused ? Color.tokenCharcoal : Color.tokenBorder)
                    .frame(height: 1)
                    .animation(reduceMotion ? nil : Motion.snappy, value: focused)
            }
            .padding(.top, Spacing.xl)

            Spacer()

            Button(action: submit) {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .brandPillStyle()
            .disabled(!canSubmit)
            .opacity(canSubmit ? 1 : 0.5)
            .padding(.bottom, Spacing.xl)
        }
        .padding(.horizontal, Spacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        // 50ms autofocus — without this the keyboard sometimes loses focus to
        // the sheet's presentation animation (Screen specs.md).
        .task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            focused = true
        }
        .onDisappear {
            text = ""
        }
    }

    // MARK: - Submit

    private func submit() {
        guard canSubmit else { return }
        store.add(text: trimmedText)
        HapticEngine.success(reduceMotion: reduceMotion)
        store.fireConfetti()
        dismiss()
    }
}

#Preview {
    LogSheet()
        .modelContainer(for: DoneItem.self, inMemory: true)
        .environment(DoneStore())
}
