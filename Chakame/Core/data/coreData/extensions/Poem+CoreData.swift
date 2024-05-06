//
//  Poem+CoreData.swift
//  Chakame
//
//  Created by Milad on 2024-02-02.
//

import CoreData

// MARK: - UUIDIdentifiable
extension Poem: UUIDIdentifiable {
    
    init(managedObject: PoemEntity) {
        self.title = managedObject.title
        self.id = Int(managedObject.id)
        self.parentId = Int(managedObject.parentId)
        self.urlSlug = managedObject.urlSlug
    }

    private func checkForExistingPoem(id: Int, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> PoemEntity? {
        let fetchRequest = PoemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
    
        if let results = try? context.fetch(fetchRequest), let poem = results.first {
            return poem
        }
        return nil
    }

    mutating func toManagedObject(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> PoemEntity {
//        guard checkForExistingPoem(id: id, context: context) == false else {
//            return
//        }
        var persistedValue: PoemEntity
        if let poem = checkForExistingPoem(id: id, context: context) {
            persistedValue = poem
        } else {
            persistedValue = PoemEntity.init(context: context)
        }
        
        persistedValue.title = self.title
        persistedValue.id = Int32(id)
        
        // checking for parentId to ensure that poems are updated correctly, as sometimes updates may occur without a parentId, causing unintended retention.
        if let parentId = parentId {
            persistedValue.parentId = Int32(parentId)
        }
        if let nextId = self.next?.id  {
            persistedValue.nextId = Int32(nextId)
        }
        if let previousId = self.previous?.id {
            persistedValue.previousId = Int32(previousId)
        }
        persistedValue.urlSlug = self.urlSlug
        persistedValue.fullTitle = self.fullTitle
        return persistedValue
    }
}
