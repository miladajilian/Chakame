//
//  Verse+SwiftData.swift
//  Chakame
//

import Foundation
import SwiftData

extension Verse {
    /// Inserts the verse for `poemId`. A verse that's already stored is left as it is.
    func upsert(into context: ModelContext, poemId: Int) throws {
        let verseId = id
        guard try context.first(where: #Predicate<VerseEntity> { $0.id == verseId }) == nil else {
            return
        }
        let entity = VerseEntity(id: id)
        entity.poemId = poemId
        entity.vOrder = vOrder ?? 0
        entity.coupletIndex = coupletIndex ?? 0
        entity.versePosition = Int(versePosition ?? 0)
        entity.text = text ?? ""
        context.insert(entity)
    }
}
