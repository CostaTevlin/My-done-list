// OnboardingFlow.swift
// 3-step first-run flow: Welcome → FirstLog → Notifications.
//
// State machine: linear progression via a `step: Int`. The flow completes by
// flipping `@AppStorage("hasOnboarded")` to `true`, regardless of the
// notification permission outcome (per Screen specs).
//
// Phase: 7, Phase 5 (token migration to sage palette)
// See: design-system/Screen specs.md (Onboarding)  · Copy bank.md
//      decisions/0008 — 4.2 risk mitigation

import SwiftUI
import SwiftData
import DesignSystem

struct OnboardingFlow: View {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var step: Int = 0

    var body: some View {
        ZStack {
            Color.surfaceApp.ignoresSafeArea()

            switch step {
            case 0:
                WelcomeStep(onContinue: advance)
                    .transition(.opacity)
            case 1:
                FirstLogStep(onLog: advance, onSkip: advance)
                    .transition(.opacity)
            default:
                NotificationsStep(onComplete: complete)
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : Motion.entranceCurve, value: step)
    }

    private func advance() {
        step += 1
    }

    private func complete() {
        hasOnboarded = true
    }
}

// MARK: - 1 · Welcome

private struct WelcomeStep: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Spacer()

            Text("My done list")
                .font(.display)
                .foregroundStyle(Color.textPrimary)

            Text("A quiet place for the things you actually got done.")
                .font(.motivational)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: 300, alignment: .leading)

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .brandPillStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xxl)
        .padding(.top, Spacing.xxxl)
        .padding(.bottom, Spacing.xxl)
    }
}

// MARK: - 2 · First log

private struct FirstLogStep: View {
    @Environment(DoneStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let onLog: () -> Void
    let onSkip: () -> Void

    @State private var text: String = ""
    @FocusState private var focused: Bool

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSubmit: Bool {
        trimmedText.count >= 2
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Spacer().frame(height: Spacing.xxxl)

            Text("Try it out")
                .font(.display)
                .foregroundStyle(Color.textPrimary)

            Text("Type something you did today.")
                .font(.motivational)
                .foregroundStyle(Color.textPrimary)

            VStack(alignment: .leading, spacing: 0) {
                TextField(
                    "",
                    text: $text,
                    prompt: Text("Took a 10-min walk")
                        .foregroundStyle(Color.textSecondary.opacity(0.6))
                )
                .font(SwiftUI.Font.body)
                .foregroundStyle(Color.textPrimary)
                .focused($focused)
                .submitLabel(.done)
                .onSubmit(submit)
                .padding(.vertical, Spacing.md)

                Rectangle()
                    .fill(focused ? Color.textPrimary : Color.borderDefault)
                    .frame(height: 1)
                    .animation(reduceMotion ? nil : Motion.snappy, value: focused)
            }
            .padding(.top, Spacing.lg)

            Spacer()

            Button(action: submit) {
                Text("Log it")
                    .frame(maxWidth: .infinity)
            }
            .brandPillStyle()
            .disabled(!canSubmit)

            Button("Skip for now", action: onSkip)
                .font(.bodySub)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.lg)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xxl)
        // Match LogSheet's 50ms autofocus delay so the keyboard catches.
        .task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            focused = true
        }
    }

    private func submit() {
        guard canSubmit else { return }
        store.add(text: trimmedText)
        HapticEngine.success(reduceMotion: reduceMotion)
        store.fireConfetti()
        onLog()
    }
}

// MARK: - 3 · Notifications

private struct NotificationsStep: View {
    let onComplete: () -> Void

    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 21       // 9 PM
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    @State private var requesting: Bool = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: reminderHour,
                    minute: reminderMinute,
                    second: 0,
                    of: .now
                ) ?? .now
            },
            set: { newValue in
                let cal = Calendar.current
                reminderHour = cal.component(.hour, from: newValue)
                reminderMinute = cal.component(.minute, from: newValue)
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Spacer().frame(height: Spacing.xxxl)

            Text("Get a daily nudge")
                .font(.display)
                .foregroundStyle(Color.textPrimary)

            Text("We'll send a single, quiet reminder at the time you choose. Nothing else. Ever.")
                .font(.motivational)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: 320, alignment: .leading)

            HStack {
                Text("Reminder time")
                    .font(.bodyText)
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                DatePicker(
                    "Reminder time",
                    selection: reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .labelsHidden()
            }
            .padding(.top, Spacing.xl)

            Spacer()

            Button(action: allow) {
                Text("Allow notifications")
                    .frame(maxWidth: .infinity)
            }
            .brandPillStyle()
            .disabled(requesting)

            Button("Maybe later", action: onComplete)
                .font(.bodySub)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.lg)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xxl)
    }

    private func allow() {
        requesting = true
        Task {
            let granted = await NotificationScheduler.requestAuthorization()
            if granted {
                reminderEnabled = true
                NotificationScheduler.scheduleDailyReminder(
                    at: reminderHour,
                    minute: reminderMinute
                )
            }
            requesting = false
            onComplete()
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingFlow()
        .modelContainer(for: DoneItem.self, inMemory: true)
        .environment(DoneStore())
}
