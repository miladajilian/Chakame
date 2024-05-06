//
//  VerseStoreService.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import CoreData

struct VerseStoreService {
    
}

extension VerseStoreService: VerseStore {
    func save(verses: [Verse], poemId: Int32) async throws {
        guard !verses.isEmpty else { return }

        await PersistenceController.shared.container.performBackgroundTask { context in
            for var verse in verses {
                verse.toManagedObject(context: context, poemId: poemId)
            }
            do {
                try context.save()
            } catch {
                
            }
        }
        
    }
}
