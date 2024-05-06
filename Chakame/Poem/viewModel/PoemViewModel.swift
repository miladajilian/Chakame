//
//  PoemViewModel.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation
import CoreData

protocol VerseStore {
    func save(verses: [Verse], poemId: Int32) async throws
}
protocol PoemStore {
    func update(poem: Poem) async throws
}

protocol PoemFetcher {
    func fetchVerses(poemId: Int32) async -> [Verse]
    func fetchPoem(poemId: Int32) async -> Poem?
}

@MainActor
final class PoemViewModel: ObservableObject {
    @Published var isLoading: Bool
    @Published var isFavorite: Bool = false
    var poem: PoemEntity
    
    
    private var poemFetcher: PoemFetcher
    private var verseStore: VerseStore = VerseStoreService()
    private var poemStore: PoemStore
    
    init(
        isLoading: Bool  = false,
        poem: PoemEntity,
        poemFetcher: PoemFetcher,
        poemStore: PoemStore
    ) {
        self.isLoading = isLoading
        self.poem = poem
        self.isFavorite = poem.isFavorite
        self.poemFetcher = poemFetcher
        self.poemStore = poemStore
    }
    
    
    func fetchVerses() async {
        guard isLoading == false else { return }
        
        isLoading = true
        
        guard let poem = await poemFetcher.fetchPoem(poemId: poem.id) else {
            return
        }
        do {
            try await verseStore.save(
                verses: poem.verses ?? [],
                poemId: self.poem.id
            )
            
            try await poemStore.update(poem: poem)
            
            self.isLoading = false
        } catch {
            print("Error storing verses ... \(error.localizedDescription)")
            self.isLoading = false
        }
    }
    
    func getVerseFetchRequest() -> NSFetchRequest<VerseEntity> {
        let verseRequest: NSFetchRequest<VerseEntity> = VerseEntity.fetchRequest()
        verseRequest.predicate = NSPredicate(
            format: "poemId = \(poem.id)"
        )
        
        verseRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \VerseEntity.vOrder, ascending: true)
        ]
        return verseRequest
    }
    
    func getPoemFetchRequest(id: Int32) -> NSFetchRequest<PoemEntity> {
        let poemRequest: NSFetchRequest<PoemEntity> = PoemEntity.fetchRequest()
        poemRequest.predicate = NSPredicate(
            format: "id = \(id)"
        )
        
        poemRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \PoemEntity.id, ascending: true)
        ]
        return poemRequest
    }
    
    func toggleFavorite() {
        Task {
            do {
                poem.isFavorite.toggle()
                self.isFavorite.toggle()
                try poem.managedObjectContext?.save()
            } catch {
                print("Error updating poem isFavotite ... \(error.localizedDescription)")
            }
        }
    }
}
