//
//  PoetEntity.swift
//  Chakame
//

import Foundation
import SwiftData

@Model
final class PoetEntity {
    @Attribute(.unique) var id: Int
    var name: String = ""
    /// The API's `description`. SwiftData doesn't allow a property named `description`.
    var bio: String = ""
    var fullUrl: String = ""
    var rootCatId: Int = 0
    var nickname: String = ""
    var published: Bool = false
    var imageUrl: String = ""
    var birthYearInLHijri: Int = 0
    var validBirthDate: Bool = false
    var deathYearInLHijri: Int = 0
    var validDeathDate: Bool = false
    var pinOrder: Int = 0
    var birthPlace: String = ""
    var birthPlaceLatitude: Double = 0
    var birthPlaceLongitude: Double = 0
    var deathPlace: String = ""
    var deathPlaceLatitude: Double = 0
    var deathPlaceLongitude: Double = 0
    var centuries: [CenturyEntity] = []

    init(id: Int) {
        self.id = id
    }
}
