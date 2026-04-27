// LogSheet.swift
// Bottom sheet with autofocused TextField + "Done" button.
// On submit: insert item · dismiss · haptic · fire confetti.
//
// Phase: 4
// See: design-system/Screen specs.md (Log sheet)  ·  decisions/0006 — Confetti

import SwiftUI

struct LogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        // Phase 4 implementation
        VStack {
            TextField("What did you do?", text: $text)
                .focused($focused)
                .task { focused = true }
            Button("Done") {
                // submit
                dismiss()
            }
        }
        .padding()
    }
}

#Preview {
    LogSheet()
}
