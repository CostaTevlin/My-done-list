// SearchView.swift
// Full-store search + browse-by-date.
// Each section header is the long date; tapping a result opens it for editing.
//
// Phase: 9, Phase 5 (token migration to sage palette)
// See: decisions/0010 — Voice-first input + FAB navigation.md

import SwiftUI
import SwiftData
import DesignSystem

struct SearchView: View {

    // MARK: - Environment

    @Environment(DoneStore.self) private var store
    @Query(sort: \DoneItem.createdAt, order: .reverse) private var allItems: [DoneItem]

    // MARK: - State

    @State private var query: String = ""
    @State private var editingItem: DoneItem? = nil

    // MARK: - Derived

    private var filtered: [DoneItem] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return allItems }
        let q = query.lowercased()
        return allItems.filter { $0.text.lowercased().contains(q) }
    }

    /// Groups items by date key, preserving reverse-chronological section order.
    private var grouped: [(key: String, items: [DoneItem])] {
        var seen: [String] = []
        var dict: [String: [DoneItem]] = [:]
        for item in filtered {
            if dict[item.date] == nil {
                seen.append(item.date)
            }
            dict[item.date, default: []].append(item)
        }
        return seen.map { (key: $0, items: dict[$0] ?? []) }
    }

    // MARK: - Body

    var body: some View {
        List {
            ForEach(grouped, id: \.key) { section in
                Section(header: Text(sectionTitle(for: section.key))
                    .font(.label)
                    .foregroundStyle(Color.textSecondary)
                    .textCase(.none)
                ) {
                    ForEach(section.items, id: \.persistentModelID) { item in
                        Button {
                            editingItem = item
                        } label: {
                            HStack(alignment: .firstTextBaseline, spacing: Spacing.md) {
                                Text(item.text)
                                    .font(.bodyText)
                                    .foregroundStyle(Color.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(item.time)
                                    .font(.time)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(item.text), at \(item.time)")
                        .accessibilityHint("Tap to edit")
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query, prompt: "Search your done list")
        .sheet(item: $editingItem) { item in
            LogSheet(initialMode: .text, editingItem: item)
                .environment(store)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(Radius.card)
        }
    }

    // MARK: - Helpers

    private func sectionTitle(for dateKey: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateKey) else { return dateKey }
        let display = DateFormatter()
        display.dateStyle = .full
        display.timeStyle = .none
        return display.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SearchView()
    }
    .modelContainer(for: DoneItem.self, inMemory: true)
    .environment(DoneStore())
}
