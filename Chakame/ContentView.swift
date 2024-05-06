//
//  ContentView.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftUI

struct ContentView: View {
    let managedObjectContext = PersistenceController.shared.container.viewContext
    var body: some View {
        TabView {
            CenturiesView(
                viewModel: CenturyViewModel(
                    centuryFetcher: FetchCenturiesService(requestManager: RequestManager.shared),
                    centuryStore: CenturyStoreService(context: PersistenceController.shared.container.newBackgroundContext())
                )
            )
            .tabItem {
                Label("Home", systemImage: "list.bullet")
            }
            FavoriteView()
                .tabItem {
                    Label("Favorite", systemImage: "heart.fill")
                }
            SettingView()
                .tabItem {
                    Label("AboutUs", systemImage: "gear")
                }
        }
        .environment(\.managedObjectContext, managedObjectContext)
    }
}

#Preview {
    ContentView()
}
