//
//  APIManagerMock.swift
//  ChakameTests
//
//  Created by Milad on 2024-01-24.
//

import Foundation
@testable import Chakame

struct APIManagerMock: APIManagerProtocol {
    func perform(_ request: RequestProtocol, authToken: String) async throws -> Data {
        return try Data(contentsOf: URL(fileURLWithPath: request.path), options: .mappedIfSafe)
    }
}
