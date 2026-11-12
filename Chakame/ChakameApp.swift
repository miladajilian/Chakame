//
//  ChakameApp.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftData
import SwiftUI

@main
struct ChakameApp: App {
    private let container: ModelContainer?
    private let dependencies: AppDependencies?

    init() {
        LegacyStoreCleaner.removeLegacyStore()
        do {
            let container = try ModelContainerFactory.make()
            self.container = container
            self.dependencies = AppDependencies(container: container)
        } catch {
            print("Error opening the data store: \(error.localizedDescription)")
            self.container = nil
            self.dependencies = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if let container, let dependencies {
                ContentView(dependencies: dependencies)
                    .modelContainer(container)
            } else {
                StoreUnavailableView()
            }
        }
    }
}
