//
//  Int+Persian.swift
//  Chakame
//

import Foundation

extension Int {
    /// The number in Persian digits (e.g. "۱۲"), to match the Persian UI.
    var persianFormatted: String {
        formatted(.number.locale(Locale(identifier: "fa")))
    }
}
