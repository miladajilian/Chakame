//
//  Category+CoreData.swift
//  Chakame
//
//  Created by Milad on 2024-02-02.
//

import CoreData

// MARK: - UUIDIdentifiable
extension Category: UUIDIdentifiable {
    init(managedObject: CategoryEntity) {
        self.title = managedObject.title
        self.id = Int(managedObject.id)
        self.parentId = Int(managedObject.parentId)
        self.urlSlug = managedObject.urlSlug
        self.fullUrl = managedObject.fullUrl
    }

    private func checkForExistingCategory(
        id: Int,
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) -> Bool {
        let fetchRequest = CategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        if let results = try? context.fetch(fetchRequest), results.first != nil {
            return true
        }
        return false
    }

  mutating func toManagedObject(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
      guard checkForExistingCategory(id: id, context: context) == false else {
          return
      }
      let persistedValue = CategoryEntity.init(context: context)
      persistedValue.title = self.title
      persistedValue.id = Int32(id)
      persistedValue.parentId = Int32(parentId ?? 0)
      persistedValue.fullUrl = self.fullUrl
      persistedValue.urlSlug = self.urlSlug
  }
}
