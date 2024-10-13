//
//  Endpoint.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import Foundation

protocol EndpointProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
}

// MARK: - Enums

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Endpoint: EndpointProtocol {
    var baseURL: URL
    var path: String
    var method: HTTPMethod
    var headers: [String: String]?
    var parameters: [String: Any]?
    
    init(baseURL: URL, path: String, method: HTTPMethod = .get, headers: [String: String]? = nil, parameters: [String: Any]? = nil) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
}
