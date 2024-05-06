//
//  Poet+CoreData.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import CoreData

// MARK: - UUIDIdentifiable
extension Poet: UUIDIdentifiable {
    
    init(managedObject: PoetEntity) {
        self.name = managedObject.name
        self.id = Int(managedObject.id)
        self.description = managedObject.des
        self.fullUrl = managedObject.fullUrl
        self.rootCatId = Int(managedObject.rootCatId)
        self.nickname = managedObject.nickname
        self.published = managedObject.published
        self.imageUrl = managedObject.imageUrl
        self.birthYearInLHijri = managedObject.birthYearInLHijri
        self.validBirthDate = managedObject.validBirthDate
        self.deathYearInLHijri = managedObject.deathYearInLHijri
        self.validDeathDate = managedObject.validDeathDate
        self.pinOrder = managedObject.pinOrder
        self.birthPlace = managedObject.birthPlace
        self.birthPlaceLatitude = managedObject.birthPlaceLatitude
        self.birthPlaceLongitude = managedObject.birthPlaceLongitude
        self.deathPlace = managedObject.deathPlace
        self.deathPlaceLatitude = managedObject.deathPlaceLatitude
        self.deathPlaceLongitude = managedObject.deathPlaceLongitude
    }

  private func checkForExistingPoet(id: Int, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> PoetEntity? {
    let fetchRequest = PoetEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id = %d", id)

    if let results = try? context.fetch(fetchRequest), let result = results.first {
      return result
    }
    return nil
  }

  mutating func toManagedObject(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> PoetEntity {
//      guard let id = self.id else {
//          return nil
//      }
      if let poet =  checkForExistingPoet(id: id, context: context) {
          return poet
      }
      let persistedValue = PoetEntity.init(context: context)
      persistedValue.name = self.name
      persistedValue.id = Int32(id)
      persistedValue.des = self.description
      persistedValue.fullUrl = self.fullUrl
      persistedValue.rootCatId = Int32(self.rootCatId ?? 0)
      persistedValue.nickname = self.nickname
      persistedValue.published = self.published ?? false
      persistedValue.imageUrl = self.imageUrl
      persistedValue.birthYearInLHijri = self.birthYearInLHijri ?? 0
      persistedValue.validBirthDate = self.validBirthDate ?? false
      persistedValue.deathYearInLHijri = self.deathYearInLHijri ?? 0
      persistedValue.validDeathDate = self.validDeathDate ?? false
      persistedValue.pinOrder = self.pinOrder ?? 0
      persistedValue.birthPlace = self.birthPlace
      persistedValue.birthPlaceLatitude = self.birthPlaceLatitude ?? 0
      persistedValue.birthPlaceLongitude = self.birthPlaceLongitude ?? 0
      persistedValue.deathPlace = self.deathPlace
      persistedValue.deathPlaceLatitude = self.deathPlaceLatitude ?? 0
      persistedValue.deathPlaceLongitude = self.deathPlaceLongitude ?? 0
      
      return persistedValue
  }
}
