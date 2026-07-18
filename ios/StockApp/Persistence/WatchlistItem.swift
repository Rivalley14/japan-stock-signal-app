import Foundation
import SwiftData

@Model
final class WatchlistItem {
    @Attribute(.unique) var code: String
    var name: String
    var addedAt: Date

    init(code: String, name: String, addedAt: Date = .now) {
        self.code = code
        self.name = name
        self.addedAt = addedAt
    }
}
