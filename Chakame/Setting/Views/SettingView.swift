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
        NavigationView {
            VStack {
                Form {
                    Section {
                        Toggle("Keep Screen Always On", isOn: $alwaysOn)
                            .onChange(of: alwaysOn) { newValue in
                                UIApplication.shared.isIdleTimerDisabled = newValue
                            }
                        Text("When enabled, your screen will stay awake while using the app.")
                            .font(.customcaption1)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Text("AboutUsText")
                    .font(.customcaption1)
                HStack(spacing: 4) {
                    Text((appVersion ?? ""))
                    Text("version")
                }
                .font(.customcaption1)
            }
            .font(.customBody)
            .environment(\.layoutDirection, .rightToLeft)
            .navigationTitle("Setting")
        }
    }
}

#Preview {
    SettingView()
}
