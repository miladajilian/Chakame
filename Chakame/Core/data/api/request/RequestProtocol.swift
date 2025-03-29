//
//  RequestProtocol.swift
//  Chakame
//
//  Created by Milad on 2024-01-24.
//

import Foundation

protocol RequestProtocol {
    var path: String { get }
    var headers: [String: String] { get }
    var params: [String: Any] { get }
    var urlParams: [String: String?] { get }
    var addAuthorizationToken: Bool { get }
    var requestType: RequestType { get }
}

extension RequestProtocol {
    var host: String {
        Constants.API.host
    }
    var addAuthorizationToken: Bool {
        false
    }
    var params: [String: Any] {
        [:]
    }
    var urlParams: [String: String?] {
        [:]
    }
    var headers: [String: String] {
        [:]
    }

    func createURLRequest(authToken: String) throws -> URLRequest {
        var component = URLComponents()
        component.scheme = "https"
        component.host = host
        component.path = path

        if !urlParams.isEmpty {
            component.queryItems = urlParams.map({
                URLQueryItem(name: $0, value: $1)
            })
        }

        guard let url = component.url else { throw NetworkError.invalidURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType.rawValue

        if !headers.isEmpty {
            urlRequest.allHTTPHeaderFields = headers
        }

        if addAuthorizationToken {
            urlRequest.setValue(authToken, forHTTPHeaderField: "Authorization")
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")

        if !params.isEmpty {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params)
        }

        return urlRequest
    }
}
