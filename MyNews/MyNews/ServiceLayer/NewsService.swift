//
//  NewsService.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import Foundation

protocol NewsServiceProtocol {
    func fetchTopHeadlines(category: String?) async throws -> [Article]
}

class NewsService: NewsServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchTopHeadlines(category: String? = nil) async throws -> [Article] {
        let endpoint = NewsAPI.getTopHeadlines(category: category)
        let response: NewsResponse = try await networkService.request(endpoint)
        return response.articles
    }
}

struct NewsAPI {
    static let baseURL = URL(string: "https://newsapi.org/v2/")!
    static let apiKey = "2df67bfc8c654a1bb0cd9980e15656cb"
    static let country = "us"
    static func getTopHeadlines(category: String? = nil) -> Endpoint {
        var parameters: [String: Any] = ["apiKey": apiKey]
        parameters["country"] = country
        if let category = category {
            parameters["category"] = category
        }
        
        return Endpoint(
            baseURL: baseURL,
            path: "top-headlines",
            method: .get,
            headers: ["Content-Type": "application/json"],
            parameters: parameters
        )
    }
}
