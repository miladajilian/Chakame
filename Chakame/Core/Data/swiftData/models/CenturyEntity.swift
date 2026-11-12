//
//  CenturyEntity.swift
//  Chakame
//

import Foundation
import SwiftData

@Model
final class CenturyEntity {
    @Attribute(.unique) var id: Int
    var name: String = ""
    var halfCenturyOrder: Int = 0
    var startYear: Int = 0
    var endYear: Int = 0
    var showInTimeLine: Bool = true

    /// Many-to-many: a poet can be in its own century and in "Popular Poets" (id 0).
    @Relationship(deleteRule: .nullify, inverse: \PoetEntity.centuries)
    var poets: [PoetEntity] = []

    init(id: Int) {
        self.id = id
    }
}
