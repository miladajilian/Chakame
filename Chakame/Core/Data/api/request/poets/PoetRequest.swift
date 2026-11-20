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
    /// Poems containing `term`. `catId` only narrows the search when `poetId` is set too.
    case searchPoems(term: String, poetId: Int, catId: Int, page: Int, pageSize: Int)
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
        case .searchPoems:
            "/api/ganjoor/poems/search"
        }
    }

    var urlParams: [String: String?] {
        switch self {
        case let .searchPoems(term, poetId, catId, page, pageSize):
            var params: [String: String?] = [
                "term": term,
                "PageNumber": "\(page)",
                "PageSize": "\(pageSize)"
            ]
            if poetId != 0 {
                params["poetId"] = "\(poetId)"
                if catId != 0 {
                    params["catId"] = "\(catId)"
                }
            }
            return params
        default:
            return [:]
        }
    }

    var addAuthorizationToken: Bool {
        false
    }

    var requestType: RequestType {
        .GET
    }
}
