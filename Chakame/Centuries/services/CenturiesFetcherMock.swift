//
//  CenturiesFetcherMock.swift
//  Chakame
//
//  Created by Milad on 2024-01-28.
//

import Foundation

struct CenturiesFetcherMock: CenturiesFetcher {
    func fetchCenturies() async -> [Century] {
        Century.mock
    }
}
