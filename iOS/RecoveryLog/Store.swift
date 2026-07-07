import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [Check-inEntry] = []
    @Published var categoryTogglesOn: Bool = true

    /// Free tier limit is intentionally set well above the seed data count,
    /// so a fresh install never immediately hits the paywall.
    static let freeTierLimit = 12

    private let fileName = "recoverylog_entries.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
        if entries.isEmpty {
            seed()
        }
    }

    private func seed() {
        let now = Date()
        entries = [
            Check-inEntry(date: now.addingTimeInterval(-86400*2), note: "First entry", minutes: 10, tag: "General", rating: 2),
            Check-inEntry(date: now.addingTimeInterval(-86400), note: "Second entry", minutes: 15, tag: "General", rating: 3)
        ]
        save()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || entries.count < Store.freeTierLimit
    }

    func add(_ entry: Check-inEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: Check-inEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: Check-inEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([Check-inEntry].self, from: data) {
            entries = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
