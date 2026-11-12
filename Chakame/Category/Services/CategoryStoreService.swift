//
//  CategoryStoreService.swift
//  Chakame
//
//  Created by Milad on 2024-02-02.
//

import CoreData

struct CategoryStoreService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension CategoryStoreService: CategoryStore {
    func save(categories: [Category]) async throws {
        guard !categories.isEmpty else { return }

        await PersistenceController.shared.container.performBackgroundTask { context in
            for var category in categories {
                category.toManagedObject(context: context)
            }
            do {
                try context.save()
            } catch {
                print("Error storing category ... \(error.localizedDescription)")
            }
        }
    }

    func save(poems: [Poem]) async throws {
        await PersistenceController.shared.container.performBackgroundTask { context in
            for var poem in poems {
                _ = poem.toManagedObject(context: context)
            }
            do {
                try context.save()
            } catch {
                print("Error storing poem ... \(error.localizedDescription)")
            }
        }
    }
}
