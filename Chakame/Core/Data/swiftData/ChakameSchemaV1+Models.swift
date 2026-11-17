//
//  ChakameSchemaV1+Models.swift
//  Chakame
//
//  Frozen copies of the V1 models. They must stay exactly as they shipped.
//

import Foundation
import SwiftData

extension ChakameSchemaV1 {
    @Model
    final class CenturyEntity {
        @Attribute(.unique) var id: Int
        var name: String = ""
        var halfCenturyOrder: Int = 0
        var startYear: Int = 0
        var endYear: Int = 0
        var showInTimeLine: Bool = true

        @Relationship(deleteRule: .nullify, inverse: \PoetEntity.centuries)
        var poets: [PoetEntity] = []

        init(id: Int) {
            self.id = id
        }
    }

    @Model
    final class PoetEntity {
        @Attribute(.unique) var id: Int
        var name: String = ""
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

    @Model
    final class PoemEntity {
        @Attribute(.unique) var id: Int
        var parentId: Int = 0
        var nextId: Int = 0
        var previousId: Int = 0
        var title: String = ""
        var fullTitle: String = ""
        var urlSlug: String = ""
        var isFavorite: Bool = false

        init(id: Int) {
            self.id = id
        }
    }

    @Model
    final class VerseEntity {
        @Attribute(.unique) var id: Int
        var poemId: Int = 0
        var vOrder: Int = 0
        var coupletIndex: Int = 0
        var versePosition: Int = 0
        var text: String = ""

        init(id: Int) {
            self.id = id
        }
    }
}
