//
//  Century+SwiftData.swift
//  Chakame
//

import Foundation
import SwiftData

extension Century {
    /// Inserts the century and links its poets. A century that's already stored is left as it is.
    func upsert(into context: ModelContext) throws {
        let centuryId = id
        guard try context.first(where: #Predicate<CenturyEntity> { $0.id == centuryId }) == nil else {
            return
        }
        let entity = CenturyEntity(id: id)
        entity.name = name ?? ""
        entity.halfCenturyOrder = Int(halfCenturyOrder ?? 0)
        entity.startYear = Int(startYear ?? 0)
        entity.endYear = Int(endYear ?? 0)
        entity.showInTimeLine = showInTimeLine ?? true
        context.insert(entity)
        entity.poets = try poets.map { try $0.upsert(into: context) }
    }
}
