//
//  DataParser.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

protocol DataParserProtocol {
    func parser<T: Decodable>(data: Data) throws -> T
}

class DataParser: DataParserProtocol {
    private var jsonDecoder: JSONDecoder

    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
//        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func parser<T: Decodable>(data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}
