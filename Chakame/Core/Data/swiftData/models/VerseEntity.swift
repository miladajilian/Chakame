//
//  VerseEntity.swift
//  Chakame
//

import Foundation
import SwiftData

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
