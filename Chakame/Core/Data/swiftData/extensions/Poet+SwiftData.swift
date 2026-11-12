//
//  Poet+SwiftData.swift
//  Chakame
//

import Foundation
import SwiftData

extension Poet {
    /// Returns the stored poet with this id, or inserts a new one. An existing poet isn't overwritten.
    @discardableResult
    func upsert(into context: ModelContext) throws -> PoetEntity {
        let poetId = id
        if let existing = try context.first(where: #Predicate<PoetEntity> { $0.id == poetId }) {
            return existing
        }
        let entity = PoetEntity(id: id)
        entity.name = name ?? ""
        entity.bio = description ?? ""
        entity.fullUrl = fullUrl ?? ""
        entity.rootCatId = rootCatId ?? 0
        entity.nickname = nickname ?? ""
        entity.published = published ?? false
        entity.imageUrl = imageUrl ?? ""
        entity.birthYearInLHijri = Int(birthYearInLHijri ?? 0)
        entity.validBirthDate = validBirthDate ?? false
        entity.deathYearInLHijri = Int(deathYearInLHijri ?? 0)
        entity.validDeathDate = validDeathDate ?? false
        entity.pinOrder = Int(pinOrder ?? 0)
        entity.birthPlace = birthPlace ?? ""
        entity.birthPlaceLatitude = birthPlaceLatitude ?? 0
        entity.birthPlaceLongitude = birthPlaceLongitude ?? 0
        entity.deathPlace = deathPlace ?? ""
        entity.deathPlaceLatitude = deathPlaceLatitude ?? 0
        entity.deathPlaceLongitude = deathPlaceLongitude ?? 0
        context.insert(entity)
        return entity
    }
}
