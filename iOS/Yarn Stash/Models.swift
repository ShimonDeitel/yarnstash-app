import Foundation

struct Yarn: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var fiber: String
    var yardageLeft: Double
    var colorway: String
}
