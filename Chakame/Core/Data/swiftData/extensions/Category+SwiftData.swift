//
//  Category+SwiftData.swift
//  Chakame
//

import Foundation
import SwiftData

extension Category {
    /// Inserts the category. A category that's already stored is left as it is.
    func upsert(into context: ModelContext) throws {
        let categoryId = id
        guard try context.first(where: #Predicate<CategoryEntity> { $0.id == categoryId }) == nil else {
            return
        }
        let entity = CategoryEntity(id: id)
        entity.parentId = parentId ?? 0
        entity.title = title ?? ""
        entity.urlSlug = urlSlug ?? ""
        entity.fullUrl = fullUrl ?? ""
        context.insert(entity)
    }
}
