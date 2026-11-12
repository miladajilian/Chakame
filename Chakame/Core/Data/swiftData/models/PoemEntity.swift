//
//  PoemEntity.swift
//  Chakame
//

import Foundation
import SwiftData

@Model
final class PoemEntity {
    @Attribute(.unique) var id: Int
    var parentId: Int = 0
    var nextId: Int = 0
    var previousId: Int = 0
    var title: String = ""
    var fullTitle: String = ""
    var urlSlug: String = ""
    /// The only user-owned data in the store; everything else is an API cache.
    var isFavorite: Bool = false

    init(id: Int) {
        self.id = id
    }
}
