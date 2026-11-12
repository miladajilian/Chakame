//
//  SettingView.swift
//  Chakame
//
//  Created by Milad on 2024-03-11.
//

import SwiftUI

struct SettingView: View {
    let viewModel: SettingViewModel
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    @AppStorage(Constants.UserDefaultsKeys.alwaysOn) private var alwaysOn: Bool = false
    @State private var isConfirmingRefresh = false

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

                refreshSection

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
            .confirmationDialog(
                "Refresh all poems?",
                isPresented: $isConfirmingRefresh,
                titleVisibility: .visible
            ) {
                Button("Clear and Refresh", role: .destructive) {
                    Task { await viewModel.refreshFromGanjoor() }
                }
            } message: {
                Text("RefreshConfirmationMessage")
            }
        }
    }

    private var refreshSection: some View {
        Section {
            Button {
                isConfirmingRefresh = true
            } label: {
                HStack {
                    Label("Refresh Poems from Ganjoor", systemImage: "arrow.clockwise")
                    Spacer()
                    if viewModel.refreshState == .refreshing {
                        ProgressView()
                    }
                }
            }
            .disabled(viewModel.refreshState == .refreshing)
        } footer: {
            VStack(alignment: .leading, spacing: 6) {
                Text("RefreshExplanation")
                switch viewModel.refreshState {
                case .refreshed:
                    Label("Saved data was cleared. Poems now load fresh from Ganjoor.", systemImage: "checkmark.circle")
                        .foregroundStyle(.green)
                case .failed:
                    Label("Couldn't clear the saved data. Please try again.", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                case .idle, .refreshing:
                    EmptyView()
                }
            }
            .font(.customcaption1)
        }
    }
}

#Preview {
    SettingView(viewModel: SettingViewModel(cacheStore: CacheStoreMock(), reload: {}))
        .environment(\.layoutDirection, .rightToLeft)
}
