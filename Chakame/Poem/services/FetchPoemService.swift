//
//  FetchPoemService.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation
struct FetchPoemService {
    private let requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
    }
}

extension FetchPoemService: PoemFetcher {
    func fetchVerses(poemId: Int32) async -> [Verse] {
        let requestData = ChakameRequest.getVerses(poemId: "\(poemId)")
        do {
            let verseContainer: VerseContainer = try await requestManager.perform(requestData)
            return verseContainer.verses
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func fetchPoem(poemId: Int32) async -> Poem? {
        let requestData = ChakameRequest.getPoem(poemId: "\(poemId)")
        do {
            let poem: Poem = try await requestManager.perform(requestData)
            return poem
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
