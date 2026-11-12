//
//  CacheStoreMock.swift
//  Chakame
//

import Foundation

/// Does nothing, for previews.
struct CacheStoreMock: CacheStore {
    func clearCache() throws {}
}
