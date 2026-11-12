//
//  LegacyStoreCleaner.swift
//  Chakame
//

import Foundation

/// Deletes the old Core Data store (`Chakame.sqlite`) left by versions before SwiftData.
/// Its data isn't migrated: everything in it is re-downloadable except favorites.
enum LegacyStoreCleaner {
    static let legacyFileNames = ["Chakame.sqlite", "Chakame.sqlite-shm", "Chakame.sqlite-wal"]

    static func removeLegacyStore(
        in directory: URL = .applicationSupportDirectory,
        fileManager: FileManager = .default
    ) {
        for name in legacyFileNames {
            let url = directory.appending(path: name)
            guard fileManager.fileExists(atPath: url.path(percentEncoded: false)) else { continue }
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("Error removing legacy store file \(name): \(error.localizedDescription)")
            }
        }
    }
}
