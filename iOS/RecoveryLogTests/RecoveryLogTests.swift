import XCTest
@testable import RecoveryLog

@MainActor
final class RecoveryLogTests: XCTestCase {

    func testSeedDataBelowFreeLimit() {
        let store = Store()
        XCTAssertLessThan(store.entries.count, Store.freeTierLimit)
    }

    func testAddEntryIncreasesCount() {
        let store = Store()
        let before = store.entries.count
        store.add(Check-inEntry(note: "test"))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddWithinFreeLimit() {
        let store = Store()
        XCTAssertTrue(store.canAdd(isPro: false))
    }

    func testCanAddBlockedAtLimitWhenNotPro() {
        let store = Store()
        store.entries = (0..<Store.freeTierLimit).map { _ in Check-inEntry() }
        XCTAssertFalse(store.canAdd(isPro: false))
    }

    func testCanAddAlwaysAllowedWhenPro() {
        let store = Store()
        store.entries = (0..<(Store.freeTierLimit + 5)).map { _ in Check-inEntry() }
        XCTAssertTrue(store.canAdd(isPro: true))
    }

    func testDeleteEntryRemovesIt() {
        let store = Store()
        let entry = Check-inEntry(note: "to delete")
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryPersistsChange() {
        let store = Store()
        var entry = Check-inEntry(note: "original")
        store.add(entry)
        entry.note = "updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.note, "updated")
    }

    func testDeleteAtOffsets() {
        let store = Store()
        let countBefore = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, countBefore - 1)
    }
}
