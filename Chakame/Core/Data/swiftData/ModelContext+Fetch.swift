//
//  ModelContext+Fetch.swift
//  Chakame
//

import Foundation
import SwiftData

extension ModelContext {
    /// The first model matching `predicate`, including inserts that aren't saved yet.
    func first<Model: PersistentModel>(where predicate: Predicate<Model>) throws -> Model? {
        var descriptor = FetchDescriptor<Model>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }
}
