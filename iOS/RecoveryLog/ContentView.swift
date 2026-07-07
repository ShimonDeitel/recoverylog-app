import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager

    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: Check-inEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    if store.entries.isEmpty {
                        Spacer()
                        Text("No check-ins logged yet")
                            .font(Theme.bodyFont)
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                    } else {
                        List {
                            ForEach(store.entries) { entry in
                                Button {
                                    editingEntry = entry
                                } label: {
                                    entryRow(entry)
                                }
                                .accessibilityIdentifier("entryRow_\(entry.id)")
                            }
                            .onDelete { offsets in
                                store.delete(at: offsets)
                            }
                            .listRowBackground(Theme.cardSurface)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Recovery Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                EntryEditorView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditorView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }

    @ViewBuilder
    private func entryRow(_ entry: Check-inEntry) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.tag.isEmpty ? "Check-in" : entry.tag)
                    .font(Theme.headlineFont)
                    .foregroundColor(Theme.textPrimary)
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.captionFont)
                    .foregroundColor(Theme.textSecondary)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            Spacer()
            if entry.minutes > 0 {
                Text("\(entry.minutes) min")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.accent)
            }
        }
        .padding(.vertical, 6)
    }
}

struct EntryEditorView: View {
    @Environment(\.dismiss) var dismiss
    @State private var tag: String
    @State private var note: String
    @State private var minutes: Int
    @State private var rating: Int
    @State private var date: Date
    @FocusState private var noteFocused: Bool

    let existing: Check-inEntry?
    let onSave: (Check-inEntry) -> Void

    init(entry: Check-inEntry?, onSave: @escaping (Check-inEntry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _tag = State(initialValue: entry?.tag ?? "")
        _note = State(initialValue: entry?.note ?? "")
        _minutes = State(initialValue: entry?.minutes ?? 10)
        _rating = State(initialValue: entry?.rating ?? 0)
        _date = State(initialValue: entry?.date ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Label", text: $tag)
                        .accessibilityIdentifier("tagField")
                    Stepper("Minutes: \(minutes)", value: $minutes, in: 0...600, step: 5)
                        .accessibilityIdentifier("minutesStepper")
                    DatePicker("Date", selection: $date)
                        .accessibilityIdentifier("dateField")
                }
                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .focused($noteFocused)
                        .accessibilityIdentifier("noteField")
                }
            }
            .navigationTitle(existing == nil ? "Add Check-in" : "Edit Check-in")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = existing ?? Check-inEntry()
                        entry.tag = tag
                        entry.note = note
                        entry.minutes = minutes
                        entry.rating = rating
                        entry.date = date
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                noteFocused = false
            }
        }
    }
}
