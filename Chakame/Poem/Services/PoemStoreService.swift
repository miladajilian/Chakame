//
//  PoemStoreService.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import CoreData

struct PoemStoreService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension PoemStoreService: PoemStore {
    func update(poem: Poem) async throws {
        var poemObject = poem
        _ = poemObject.toManagedObject()
        try context.save()
    }
}
