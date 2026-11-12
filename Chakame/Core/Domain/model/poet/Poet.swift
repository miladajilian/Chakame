//
//  Poet.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

struct Poet: Codable {
    var id: Int
    var name: String?
    var description: String?
    var fullUrl: String?
    var rootCatId: Int?
    var nickname: String?
    var published: Bool?
    var imageUrl: String?
    var birthYearInLHijri: Int16?
    var validBirthDate: Bool?
    var deathYearInLHijri: Int16?
    var validDeathDate: Bool?
    var pinOrder: Int16?
    var birthPlace: String?
    var birthPlaceLatitude: Double?
    var birthPlaceLongitude: Double?
    var deathPlaceLatitude: Double?
    var deathPlaceLongitude: Double?
    var deathPlace: String?
}

// MARK: Helper funcation
extension Poet {
    var completImageUrl: String? {
        guard let imageUrl = imageUrl else { return nil }
        return "https://api.ganjoor.net\(imageUrl)"
    }
}
// MARK: - Identifiable
extension Poet: Identifiable {
}
