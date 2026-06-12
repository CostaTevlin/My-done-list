// SettingsView.swift
// Account / Settings sheet — iOS 26 rebuild.
// Matches Figma Slowly-MVP node 190:11 exactly.
//
// iOS 26 specifics:
//   • Trailing "Done" toolbar button (present in Figma, was missing)
//   • .tint(Slowly.Color.accentPrimary) — sage green on Toggle tracks, links, pickers
//   • #available(iOS 26.0, *) glass nav bar via automatic NavigationStack behaviour
//   • glassEffect on avatar row header card (iOS 26 only; Material.fallback on iOS 18)
//
// AppStorage keys consumed by other phases:
//   • `hapticsEnabled`         — HapticEngine (Phase 4)
//   • `reminderEnabled`        — NotificationScheduler (Phase 7)
//   • `reminderHour` / `reminderMinute` — same
//   • `dailyTarget`            — Today indicator (future)
//   • `colorSchemePreference`  — RootTabView preferred color scheme
//
// Phase: 6 (iOS 26 rebuild)
// See: design-system/Screen specs.md (Settings) · liquid-glass.md

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
    @AppStorage("reminderHour") private var reminderHour: Int = 21
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0
    @AppStorage("dailyTarget") private var dailyTarget: Int = 0

    // MARK: - Local state

    @State private var showResetAlert = false

    /// Bridges the two `Int` AppStorage keys to the single `Date` DatePicker expects.
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
            set: {
                reminderHour   = Calendar.current.component(.hour,   from: $0)
                reminderMinute = Calendar.current.component(.minute, from: $0)
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
            #if DEBUG || INTERNAL
            debugSection
            #endif
        }
        // Sage tint propagates to Toggle tracks, segmented picker selection,
        // Link/Button foreground, and DatePicker chrome.
        .tint(Slowly.Color.accentPrimary)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Matches Figma 190:14 — "Done" trailing, semibold, sage.
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .fontWeight(.semibold)
            }
        }
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive, action: resetAllData)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This permanently deletes every item you've logged. This cannot be undone.")
        }
        // Keep UNUserNotificationCenter in sync.
        // First-time enable triggers the permission prompt; denial flips the toggle back.
        .onChange(of: reminderEnabled) { _, enabled in
            if enabled {
                Task {
                    let granted = await NotificationScheduler.requestAuthorization()
                    if granted {
                        NotificationScheduler.scheduleDailyReminder(
                            at: reminderHour, minute: reminderMinute
                        )
                    } else {
                        reminderEnabled = false
                    }
                }
            } else {
                NotificationScheduler.cancelDailyReminder()
            }
        }
        .onChange(of: reminderHour)   { _, _ in rescheduleIfNeeded() }
        .onChange(of: reminderMinute) { _, _ in rescheduleIfNeeded() }
    }

    private func rescheduleIfNeeded() {
        guard reminderEnabled else { return }
        NotificationScheduler.scheduleDailyReminder(at: reminderHour, minute: reminderMinute)
    }

    // MARK: - Sections

    @ViewBuilder
    private var accountSection: some View {
        // iCloud sync deferred to ADR-0009. Static "on this device" label until
        // the CloudKit entitlement is wired in Xcode Signing & Capabilities.
        Section {
            HStack(spacing: Spacing.md) {
                // Avatar circle — sage background with leaf icon.
                // Matches Figma 191:12 (Avatar/Circle, 36 × 36).
                ZStack {
                    Circle()
                        .fill(Slowly.Color.sage50)
                        .frame(width: 36, height: 36)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Slowly.Color.accentPrimary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Your done list")
                        .font(.bodyText)
                        .foregroundStyle(Slowly.Color.textPrimary)
                    Text("Saved on this device")
                        .font(.bodySub)
                        .foregroundStyle(Slowly.Color.textSecondary)
                }
            }
            .padding(.vertical, Spacing.xs)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Your done list, saved on this device")
        }
    }

    @ViewBuilder
    private var reminderSection: some View {
        Section("Reminder") {
            // DatePicker is intentionally disabled when the toggle is off so the
            // time is still visible but not editable — matches Figma 192:13/14.
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
            // Segmented picker — Figma 193:14/15/16 (Light · Dark · System).
            // .tint on the Form parent colours the selected segment sage.
            Picker("Appearance", selection: $colorSchemePreference) {
                Text("Light").tag("light")
                Text("Dark").tag("dark")
                Text("System").tag("system")
            }
            .pickerStyle(.segmented)

            Toggle("Haptics", isOn: $hapticsEnabled)

            // Stepper — Figma 194:12/13 ("Daily target" / "−  Off  +").
            Stepper(value: $dailyTarget, in: 0...20) {
                HStack {
                    Text("Daily target")
                    Spacer()
                    Text(dailyTarget == 0 ? "Off" : "\(dailyTarget)")
                        .foregroundStyle(Slowly.Color.textSecondary)
                        .monospacedDigit()
                }
            }
        }
    }

    @ViewBuilder
    private var dataSection: some View {
        Section("Data") {
            // Figma 194:16 — sage tinted text link, no icon shown in design.
            ShareLink(
                item: DoneListExport.from(items: allItems),
                preview: SharePreview(
                    "My Done List export",
                    image: Image(systemName: "square.and.arrow.up")
                )
            ) {
                Text("Export as JSON")
            }
            .disabled(allItems.isEmpty)

            // Figma 194:18 — destructive red, no icon shown in design.
            Button("Reset all data", role: .destructive) {
                showResetAlert = true
            }
            .disabled(allItems.isEmpty)
        }
    }

    @ViewBuilder
    private var aboutSection: some View {
        Section("About") {
            // Figma 195:13/14
            LabeledContent("Version", value: Self.versionString)

            // Figma 195:16/18 — sage text, no icons shown in design.
            Link("Privacy Policy",
                 destination: URL(string: "https://donelist-app.github.io/privacy")!)

            Link("Support",
                 destination: URL(string: "https://donelist-app.github.io/support")!)
        }
    }

    // MARK: - Internal (DEBUG + Beta builds)

    #if DEBUG || INTERNAL
    @ViewBuilder
    private var debugSection: some View {
        Section("Debug") {
            NavigationLink("Token Preview") {
                TokenPreviewView()
            }
        }
    }
    #endif

    // MARK: - Actions

    private func resetAllData() {
        do {
            try modelContext.delete(model: DoneItem.self)
            try modelContext.save()
        } catch {
            // Swallow — best-effort. Wire OSLog in Phase 9.
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
