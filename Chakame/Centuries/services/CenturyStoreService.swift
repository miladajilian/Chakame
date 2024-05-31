//
//  CenturyStoreService.swift
//  Chakame
//
//  Created by Milad on 2024-01-28.
//

import CoreData

struct CenturyStoreService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension CenturyStoreService: CenturyStore {
    func save(centuries: [Century]) async throws {
        for var century in centuries {
            century.toManagedObject(context: context)
        }
        try context.save()
    }
}
