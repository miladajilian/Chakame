//
//  SettingView.swift
//  Chakame
//
//  Created by Milad on 2024-03-11.
//

import SwiftUI

struct SettingView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

    var body: some View {
        VStack {
            Spacer()
            Image("chakame")
                .resizable()
                .frame(width: 70, height: 70)
            
            Text("Chakame")
                .font(.customTitle3)
            Text("AboutUsText")
            Spacer()
            HStack(spacing: 4) {
                Text((appVersion ?? ""))
                Text("version")
            }
            .font(.customcaption1)
            
        }
        .font(.customBody)
    }
}

#Preview {
    SettingView()
}
