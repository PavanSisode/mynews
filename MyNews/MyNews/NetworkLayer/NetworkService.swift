//
//  NetworkService.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case noResponse
    case unauthorized
    case badRequest
    case serverError
    case decodingError
}



protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

// MARK: - NetworkService

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = URL(string: endpoint.path, relativeTo: endpoint.baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let parameters = endpoint.parameters {
            if endpoint.method == .get {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = components?.url
            } else {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            }
        }
        
        print("Request ==>\(request)")
        
        let (data, response) = try await session.data(for: request)
        
        print("response ==>\(response)")
        print("data ==>\(data)")
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch (let error) {
                print(error)
                throw NetworkError.decodingError
            }
        case 400...499:
            throw NetworkError.badRequest
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.noResponse
        }
    }
}
