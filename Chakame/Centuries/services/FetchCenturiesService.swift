//
//  FetchCenturiesService.swift
//  Chakame
//
//  Created by Milad on 2024-01-28.
//

import Foundation
struct FetchCenturiesService {
    private let requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
    }
}

extension FetchCenturiesService: CenturiesFetcher {
    func fetchCenturies() async -> [Century] {
        let requestData = ChakameRequest.getCenturies
        do {
            let centuriesContainer: CenturyContainer = try await requestManager.perform(requestData)
            return centuriesContainer.centuries
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
}
