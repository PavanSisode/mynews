//
//  NewsResponse.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import Foundation


struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Codable, Hashable, Identifiable {
    let id: String
    let source: Source
    let author: String?
    let title: String
    let description: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    var isBookmarked: Bool = false
    var category = "General"
    
    enum CodingKeys: String, CodingKey {
        case id = "url"
        case source
        case author
        case title
        case description
        case urlToImage
        case publishedAt
        case content
    }
}

// MARK: - Source
struct Source: Codable, Hashable {
    let id: String?
    let name: String
}

