//
//  ContentView.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import SwiftUI

struct ContentView: View {
    /// Explicit tags: without them `TabView` tags each tab by its `.id`, and the two
    /// tabs below share `cacheGeneration`, so tapping one would select the other.
    private enum Tab {
        case home, favorite, setting
    }

    let dependencies: AppDependencies
    @AppStorage(Constants.UserDefaultsKeys.alwaysOn) private var alwaysOn: Bool = false
    @State private var selectedTab = Tab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            // A new identity after a cache clear pops every pushed screen: they hold
            // entities that were just deleted.
            CenturiesView(viewModel: dependencies.centuryViewModel)
                .id(dependencies.settingViewModel.cacheGeneration)
                .tabItem {
                    Label("Home", systemImage: "list.bullet")
                }
                .tag(Tab.home)
            FavoriteView(poemViewModel: dependencies.poemViewModel)
                .id(dependencies.settingViewModel.cacheGeneration)
                .tabItem {
                    Label("Favorite", systemImage: "heart.fill")
                }
                .tag(Tab.favorite)
            SettingView(viewModel: dependencies.settingViewModel)
                .tabItem {
                    Label("Setting", systemImage: "gear")
                }
                .tag(Tab.setting)
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
