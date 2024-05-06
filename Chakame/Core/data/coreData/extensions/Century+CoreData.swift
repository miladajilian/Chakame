//
//  Century+CoreData.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import CoreData

// MARK: - UUIDIdentifiable
extension Century: UUIDIdentifiable {
    init(managedObject: CenturyEntity) {
        self.endYear = managedObject.endYear
        self.halfCenturyOrder = managedObject.halfCenturyOrder
        self.id = Int(managedObject.id)
        self.name = managedObject.name
        self.showInTimeLine = managedObject.showInTimeLine
        self.startYear = managedObject.startYear
        let poets = managedObject.poets?.allObjects as? [PoetEntity]
        self.poets = poets?.map { Poet(managedObject: $0) } ?? []
    }
    
    private func checkForExistingCentury(id: Int, context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) -> Bool {
        let fetchRequest = CenturyEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        
        if let results = try? context.fetch(fetchRequest), results.first != nil {
            return true
        }
        return false
    }
    
    mutating func toManagedObject(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
//        guard let id = self.id else {
//            return
//        }
        
        guard checkForExistingCentury(id: id, context: context) == false else {
            return
        }
        let persistedValue = CenturyEntity.init(context: context)
        persistedValue.endYear = self.endYear ?? 0
        persistedValue.halfCenturyOrder = self.halfCenturyOrder ?? 0
        persistedValue.name = self.name
        persistedValue.showInTimeLine = self.showInTimeLine ?? true
        persistedValue.startYear = self.startYear ?? 0
        persistedValue.id = Int32(id)
        
        persistedValue.addToPoets(NSSet(array: self.poets.map { (poet: Poet) -> PoetEntity in
            var mutablePoet = poet
            return mutablePoet.toManagedObject(context: context)
        }))
    }
}
