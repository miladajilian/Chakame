//
//  ContentView.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftUI

struct ContentView: View {
    let managedObjectContext = PersistenceController.shared.container.viewContext
    @AppStorage(Constants.UserDefaultsKeys.alwaysOn) private var alwaysOn: Bool = false
    var body: some View {
        TabView {
            CenturiesView()
                .tabItem {
                    Label("Home", systemImage: "list.bullet")
                }
            FavoriteView()
                .tabItem {
                    Label("Favorite", systemImage: "heart.fill")
                }
            SettingView()
                .tabItem {
                    Label("Setting", systemImage: "gear")
                }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = alwaysOn
        }
        .environment(\.managedObjectContext, managedObjectContext)
    }
}

#Preview {
    ContentView()
}
