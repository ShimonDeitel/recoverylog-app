import Foundation

struct Check-inEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var note: String = ""
    var minutes: Int = 0
    var tag: String = ""
    var rating: Int = 0
}
