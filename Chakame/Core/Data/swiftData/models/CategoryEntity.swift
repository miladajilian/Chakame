//
//  CategoryEntity.swift
//  Chakame
//

import Foundation
import SwiftData

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: Int
    var parentId: Int = 0
    var title: String = ""
    var urlSlug: String = ""
    var fullUrl: String = ""

    init(id: Int) {
        self.id = id
    }
}
