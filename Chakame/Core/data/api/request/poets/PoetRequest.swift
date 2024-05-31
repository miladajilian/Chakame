//
//  PoetRequest.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

enum ChakameRequest: RequestProtocol {
    case getPoets
    case getCenturies
    case getCategories(parentId: String)
    case getVerses(poemId: String)
    case getPoem(poemId: String)
    var path: String {
        switch self {
        case .getCenturies:
            "/api/ganjoor/centuries"
        case .getPoets:
            "/api/ganjoor/poets"
        case let .getCategories(parentId):
            "/api/ganjoor/cat/\(parentId)"
        case let .getVerses(poemId):
            "/api/ganjoor/poem/\(poemId)/verses"
        case let .getPoem(poemId):
            "/api/ganjoor/poem/\(poemId)"
        }
    }

    var addAuthorizationToken: Bool {
        false
    }

    var requestType: RequestType {
        .GET
    }
}
