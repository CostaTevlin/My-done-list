// SettingsView.swift
// Native iOS `Form` with four sections: Reminder · Experience · Data · About.
//
// Backed by `@AppStorage` keys that other phases consume:
//   • `hapticsEnabled`     — read by HapticEngine (Phase 4)
//   • `reminderEnabled`    — read by NotificationScheduler (Phase 7)
//   • `reminderHour` / `reminderMinute` — same
//   • `dailyTarget`        — reserved for future Today indicator
//
// Phase: 6
// See: design-system/Screen specs.md (Settings)  · Architecture.md (Notifications)

import SwiftUI
import SwiftData
import DesignSystem

struct SettingsView: View {

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allItems: [DoneItem]

    // MARK: - AppStorage

    @AppStorage(HapticEngine.settingsKey) private var hapticsEnabled: Bool = true
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "dark"
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 21      // 9 PM
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    @AppStorage("dailyTarget") private var dailyTarget: Int = 0

    // MARK: - Local state

    @State private var showResetAlert: Bool = false

    /// Bridges the two `Int` `@AppStorage` keys to the single `Date` SwiftUI's
    /// `DatePicker` expects. Writes back into the two keys on change.
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                let cal = Calendar.current
                return cal.date(
                    bySettingHour: reminderHour,
                    minute: reminderMinute,
                    second: 0,
                    of: Date.now
                ) ?? Date.now
            },
            set: { newValue in
                let cal = Calendar.current
                reminderHour = cal.component(.hour, from: newValue)
                reminderMinute = cal.component(.minute, from: newValue)
            }
        )
    }

    // MARK: - Body

    var body: some View {
        Form {
            accountSection
            reminderSection
            experienceSection
            dataSection
            aboutSection
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive, action: resetAllData)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This permanently deletes every item you've logged. This cannot be undone.")
        }
        // Reminder lifecycle — keep `UNUserNotificationCenter` in sync with
        // the Settings toggle and time picker. First-time enable triggers the
        // permission ask; denial flips the toggle back off.
        .onChange(of: reminderEnabled) { _, enabled in
            if enabled {
                Task {
                    let granted = await NotificationScheduler.requestAuthorization()
                    if granted {
                        NotificationScheduler.scheduleDailyReminder(
                            at: reminderHour,
                            minute: reminderMinute
                        )
                    } else {
                        reminderEnabled = false
                    }
                }
            } else {
                NotificationScheduler.cancelDailyReminder()
            }
        }
        .onChange(of: reminderHour) { _, _ in rescheduleIfNeeded() }
        .onChange(of: reminderMinute) { _, _ in rescheduleIfNeeded() }
    }

    private func rescheduleIfNeeded() {
        guard reminderEnabled else { return }
        NotificationScheduler.scheduleDailyReminder(
            at: reminderHour,
            minute: reminderMinute
        )
    }

    // MARK: - Sections

    @ViewBuilder
    private var accountSection: some View {
        // iCloud sync arrives in ADR-0009. Until the iCloud capability is
        // enabled in Xcode (Signing & Capabilities → +Capability → iCloud,
        // tick CloudKit), CKContainer.accountStatus() spams CK errors
        // because the app is missing com.apple.developer.icloud-services.
        // For now: static "on this device" label. Swap to a CKContainer
        // check once the entitlement is wired.
        Section {
            HStack(spacing: Spacing.md) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.tokenCharcoal)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your done list")
                        .font(.tokenBody)
                        .foregroundStyle(Color.tokenCharcoal)
                    Text("Saved on this device")
                        .font(.tokenBodySub)
                        .foregroundStyle(Color.tokenMid)
                }
            }
            .padding(.vertical, Spacing.xs)
            .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder
    private var reminderSection: some View {
        Section("Reminder") {
            DatePicker(
                "Daily reminder",
                selection: reminderTime,
                displayedComponents: .hourAndMinute
            )
            .disabled(!reminderEnabled)

            Toggle("Show reminder", isOn: $reminderEnabled)
        }
    }

    @ViewBuilder
    private var experienceSection: some View {
        Section("Experience") {
            Picker("Appearance", selection: $colorSchemePreference) {
                Text("Light").tag("light")
                Text("Dark").tag("dark")
                Text("System").tag("system")
            }
            .pickerStyle(.segmented)

            Toggle("Haptics", isOn: $hapticsEnabled)

            Stepper(value: $dailyTarget, in: 0...20) {
                HStack {
                    Text("Daily target")
                    Spacer()
                    Text(dailyTarget == 0 ? "Off" : "\(dailyTarget)")
                        .foregroundStyle(Color.tokenMid)
                        .monospacedDigit()
                }
            }
        }
    }

    @ViewBuilder
    private var dataSection: some View {
        Section("Data") {
            ShareLink(
                item: DoneListExport.from(items: allItems),
                preview: SharePreview(
                    "My Done List export",
                    image: Image(systemName: "square.and.arrow.up")
                )
            ) {
                Label("Export as JSON", systemImage: "square.and.arrow.up")
            }
            .disabled(allItems.isEmpty)

            Button(role: .destructive) {
                showResetAlert = true
            } label: {
                Label("Reset all data", systemImage: "trash")
            }
            .disabled(allItems.isEmpty)
        }
    }

    @ViewBuilder
    private var aboutSection: some View {
        Section("About") {
            LabeledContent("Version", value: Self.versionString)

            Link(destination: URL(string: "https://donelist-app.github.io/privacy")!) {
                Label("Privacy Policy", systemImage: "lock.shield")
            }

            Link(destination: URL(string: "https://donelist-app.github.io/support")!) {
                Label("Support", systemImage: "questionmark.circle")
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Outfit by Smith Studio")
                Text("Open Font License 1.1")
            }
            .font(.tokenBodySub)
            .foregroundStyle(Color.tokenLight)
            .accessibilityElement(children: .combine)
        }
    }

    // MARK: - Actions

    private func resetAllData() {
        do {
            try modelContext.delete(model: DoneItem.self)
            try modelContext.save()
        } catch {
            // Swallow — SwiftData reset is best-effort. A logging hook
            // could be added in Phase 9 when we wire OSLog.
        }
    }

    // MARK: - Version helper

    private static var versionString: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(short) (\(build))"
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: DoneItem.self, inMemory: true)
}
