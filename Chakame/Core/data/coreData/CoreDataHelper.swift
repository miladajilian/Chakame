//
//  CoreDataHelper.swift
//  Chakame
//
//  Created by Milad on 2024-01-25.
//

import CoreData

enum CoreDataHelper {
  static let context = PersistenceController.shared.container.viewContext
  static let previewContext = PersistenceController.preview.container.viewContext

  static func clearDatabase() {
    let entities = PersistenceController.shared.container.managedObjectModel.entities
    entities.compactMap(\.name).forEach(clearTable)
  }

  private static func clearTable(_ entity: String) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
      try context.execute(deleteRequest)
      try context.save()
    } catch {
      fatalError("\(#file), \(#function), \(error.localizedDescription)")
    }
  }
}

// MARK: - Deleting Data
extension Collection where Element == NSManagedObject, Index == Int {
  func delete(at indices: IndexSet, inViewContext viewContext: NSManagedObjectContext = CoreDataHelper.context) {
    indices.forEach { index in
      viewContext.delete(self[index])
    }

    do {
      try viewContext.save()
    } catch {
      fatalError("""
        \(#file), \
        \(#function), \
        \(error.localizedDescription)
      """)
    }
  }
}

// MARK: - Xcode Previews Content
extension CoreDataHelper {
    static func getTestCentury() -> Century? {
        let fetchRequest = CenturyEntity.fetchRequest()
        if let results = try? previewContext.fetch(fetchRequest),
           let first = results.first {
            return Century(managedObject: first)
        }
        return nil
    }

    static func getTestCenturies() -> [Century]? {
        let fetchRequest = CenturyEntity.fetchRequest()

        if let results = try? previewContext.fetch(fetchRequest), !results.isEmpty {
            return results.map(Century.init(managedObject:))
        }
        return nil
    }

    static func getTestCenturyEntity() -> CenturyEntity? {
        let fetchRequest = CenturyEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        guard let results = try? previewContext.fetch(fetchRequest),
              let first = results.first else { return nil }
        return first
    }

    static func getTestCenturyEntities() -> [CenturyEntity]? {
        let fetchRequest = CenturyEntity.fetchRequest()
        guard let results = try? previewContext.fetch(fetchRequest),
              !results.isEmpty else { return nil }
        return results
    }

    static func getTestPoetEntity() -> PoetEntity? {
        let fetchRequest = PoetEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        guard let results = try? previewContext.fetch(fetchRequest),
              let first = results.first else { return nil }
        return first
    }

    static func getTestPoem() -> PoemEntity? {
        let fetchRequest = PoemEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        guard let results = try? previewContext.fetch(fetchRequest),
              let first = results.first else { return nil }
        return first
    }

    static func getTestPoems() -> [PoemEntity]? {
        let fetchRequest = PoemEntity.fetchRequest()
        guard let results = try? previewContext.fetch(fetchRequest) else { return nil }
        return results
    }
}
