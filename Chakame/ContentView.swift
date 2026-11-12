//
//  ContentView.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftUI

struct ContentView: View {
    let dependencies: AppDependencies
    @AppStorage(Constants.UserDefaultsKeys.alwaysOn) private var alwaysOn: Bool = false

    var body: some View {
        TabView {
            CenturiesView(viewModel: dependencies.centuryViewModel)
                .tabItem {
                    Label("Home", systemImage: "list.bullet")
                }
            FavoriteView(poemViewModel: dependencies.poemViewModel)
                .tabItem {
                    Label("Favorite", systemImage: "heart.fill")
                }
            SettingView()
                .tabItem {
                    Label("Setting", systemImage: "gear")
                }
        }
        .minimizeTabBarOnScroll()
        // Applied at the root so the system chrome (tab bar, navigation bars) is RTL too.
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = alwaysOn
        }
    }
}

#Preview {
    if let container = PreviewContainer.shared {
        ContentView(dependencies: .preview(container: container))
            .modelContainer(container)
    }
}
