import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Yarn] = []
    @Published var isPro: Bool = false

    static let freeLimit = 30

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("yarnstash", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Yarn) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: Yarn) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Yarn) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Yarn].self, from: data) {
            items = decoded
        } else {
            items = Store.seedData
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    static var seedData: [Yarn] {
        [
        Yarn(id: UUID(), title: "Malabrigo Worsted", fiber: "Merino", yardageLeft: 210.0, colorway: "Ochre"),
        Yarn(id: UUID(), title: "Cascade 220", fiber: "Wool", yardageLeft: 180.0, colorway: "Natural"),
        Yarn(id: UUID(), title: "Cotton Fine", fiber: "Cotton", yardageLeft: 90.0, colorway: "Sky Blue")
        ]
    }
}
