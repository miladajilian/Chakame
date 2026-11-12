//
//  Persistence.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import CoreData
struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for centuryIndex in 0..<3 {
            var century = Century.mock[centuryIndex]
            century.toManagedObject(context: viewContext)
        }
        var poem = Poem.mock
        _ = poem?.toManagedObject()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
      container = NSPersistentContainer(name: "Chakame")
      if inMemory {
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
      }
      container.loadPersistentStores { _, error in
        if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      }
      container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
      container.viewContext.automaticallyMergesChangesFromParent = true
    }

    static func save() {
      let context =
      PersistenceController.shared.container.viewContext
      guard context.hasChanges else { return }

      do {
        try context.save()
      } catch {
        fatalError("""
          \(#file), \
          \(#function), \
          \(error.localizedDescription)
        """)
      }
    }
  }
