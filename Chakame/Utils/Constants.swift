//
//  Constants.swift
//  Chakame
//
//  Created by Milad on 2025-03-29.
//

import Foundation

enum Constants {
    enum UserDefaultsKeys {
        static let alwaysOn = "alwaysOn"
    }

    enum API {
        static let host = "api.ganjoor.net"
        static let url = "https://api.ganjoor.net"
    }

    enum AppStore {
        static let appID = "6502296466"
        static let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review")
    }
}
