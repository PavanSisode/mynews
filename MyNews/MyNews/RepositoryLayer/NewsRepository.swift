//
//  NewsRepository.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import Foundation

protocol NewsRepositoryProtocol {
    func getNews(category: String?) async throws -> [Article]
    func bookmarkArticle(_ article: Article) throws
    func unbookmarkArticle(_ article: Article) throws
    func getBookmarkedArticles() throws -> [Article]
}

class NewsRepository: NewsRepositoryProtocol {
    
    private let newsService: NewsServiceProtocol
    private let storageManager: StorageManagerProtocol
    
    init(newsService: NewsServiceProtocol, storageManager: StorageManagerProtocol) {
        self.newsService = newsService
        self.storageManager = storageManager
    }
    
    func getNews(category: String?) async throws -> [Article] {
        let articles = try await newsService.fetchTopHeadlines(category: category)
        return articles.map { article in
            var updatedArticle = article
            updatedArticle.isBookmarked = storageManager.isArticleBookmarked(article.id)
            return updatedArticle
        }
    }
    
    func bookmarkArticle(_ article: Article) throws {
        try storageManager.saveArticle(article)
    }
    
    func unbookmarkArticle(_ article: Article) throws {
        try storageManager.removeBookmark(for: article.id)
    }
    
    func getBookmarkedArticles() throws -> [Article] {
        return try storageManager.fetchBookmarkedArticles()
    }
}

