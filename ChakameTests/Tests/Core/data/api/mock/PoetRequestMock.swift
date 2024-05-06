//
//  PoetRequestMock.swift
//  ChakameTests
//
//  Created by Milad on 2024-01-24.
//

import Foundation
@testable import Chakame

enum PoetRequestMock: RequestProtocol {
    case getPoets
    case getCenturies
    
    var requestType: RequestType {
        return .GET
    }
    
    var path: String {
        switch self {
        case .getCenturies:
            guard let path = Bundle.main.path(forResource: "CenturiesMock", ofType: "json") else {
                return ""
            }
            return path
        case .getPoets:
            guard let path = Bundle.main.path(forResource: "PoetsMock", ofType: "json") else {
                return ""
            }
            return path
        }
    }
}
