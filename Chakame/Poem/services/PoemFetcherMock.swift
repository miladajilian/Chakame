//
//  PoemFetcherMock.swift
//  Chakame
//
//  Created by Milad on 2024-02-18.
//

import Foundation

struct PoemFetcherMock: PoemFetcher {
    func fetchVerses(poemId: Int32) async -> [Verse] {
        Verse.mock
    }
    func fetchPoem(poemId: Int32) async -> Poem? {
        Poem.mock
    }
}

