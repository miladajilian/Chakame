//
//  SettingView.swift
//  Chakame
//
//  Created by Milad on 2024-03-11.
//

import SwiftUI

struct SettingView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    @AppStorage(Constants.UserDefaultsKeys.alwaysOn) private var alwaysOn: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Keep Screen Always On", isOn: $alwaysOn)
                        .onChange(of: alwaysOn) { _, newValue in
                            UIApplication.shared.isIdleTimerDisabled = newValue
                        }
                } footer: {
                    Text("When enabled, your screen will stay awake while using the app.")
                        .font(.customcaption1)
                }

                // Lives inside the Form so it scrolls with the content instead of
                // sitting under the floating tab bar.
                Section {} footer: {
                    VStack(spacing: 4) {
                        Text("AboutUsText")
                        HStack(spacing: 4) {
                            Text(appVersion ?? "")
                            Text("version")
                        }
                    }
                    .font(.customcaption1)
                    .frame(maxWidth: .infinity)
                }
            }
            .font(.customBody)
            .navigationTitle("Setting")
        }
    }
}

#Preview {
    SettingView()
        .environment(\.layoutDirection, .rightToLeft)
}
