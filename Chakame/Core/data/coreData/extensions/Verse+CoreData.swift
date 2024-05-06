//
//  Verse+CoreData.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import CoreData

// MARK: - UUIDIdentifiable
extension Verse: UUIDIdentifiable {
    init(managedObject: VerseEntity) {
        self.text = managedObject.text
        self.id = Int(managedObject.id)
        self.vOrder = Int(managedObject.vOrder)
        self.coupletIndex = Int(managedObject.coupletIndex)
        self.versePosition = managedObject.versePosition
    }

  private func checkForExistingVerse(id: Int, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> Bool {
      let fetchRequest = VerseEntity.fetchRequest()
      fetchRequest.predicate = NSPredicate(format: "id = %d", id)
      
      if let results = try? context.fetch(fetchRequest), results.first != nil {
          return true
      }
      return false
  }

    mutating func toManagedObject(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext, poemId: Int32) {
        guard checkForExistingVerse(id: id, context: context) == false else {
            return
        }
        let persistedValue = VerseEntity.init(context: context)
        persistedValue.text = self.text
        persistedValue.id = Int32(id)
        persistedValue.poemId = poemId
        persistedValue.vOrder = Int32(self.vOrder ?? 0)
        persistedValue.coupletIndex = Int32(self.coupletIndex ?? 0)
        persistedValue.versePosition = self.versePosition ?? 0
    }
}
