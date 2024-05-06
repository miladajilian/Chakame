//
//  Centuries.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

struct Century: Codable {
    var id: Int
    var name: String?
    var halfCenturyOrder: Int16?
    var startYear: Int16?
    var endYear: Int16?
    var showInTimeLine: Bool?
    let poets: [Poet]
}

// MARK: - Identifiable
extension Century: Identifiable {
}
