//
//  CategoryRequestMock.swift
//  ChakameTests
//
//  Created by Milad on 2024-02-17.
//

import Foundation
@testable import Chakame

enum CategoryRequestMock: RequestProtocol {
    case getCategories
    
    var requestType: RequestType {
        return .GET
    }
    
    var path: String {
        switch self {
        case .getCategories:
            guard let path = Bundle.main.path(forResource: "CategoriesMock", ofType: "json") else {
                return ""
            }
            return path
        }
    }
}
