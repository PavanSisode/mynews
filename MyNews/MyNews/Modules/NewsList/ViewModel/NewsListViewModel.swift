//
//  NewsListViewModel.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import Foundation

@MainActor
class NewsListViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var bookmarkedArticles: [Article] = []
    @Published var selectedCategory: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: NewsRepositoryProtocol
    
    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadArticles() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                articles = try await repository.getNews(category: selectedCategory)
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to load articles: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func loadBookmarkedArticles() {
        Task {
            do {
                bookmarkedArticles = try repository.getBookmarkedArticles()
            } catch {
                errorMessage = "Failed to load bookmarked articles: \(error.localizedDescription)"
            }
        }
    }
    
    func toggleBookmark(for article: Article) {
        Task {
            do {
                if article.isBookmarked {
                    try repository.unbookmarkArticle(article)
                } else {
                    try repository.bookmarkArticle(article)
                }
                await MainActor.run {
                    if let index = articles.firstIndex(where: { $0.id == article.id }) {
                        articles[index].isBookmarked.toggle()
                    }
                    loadBookmarkedArticles()
                }
            } catch {
                errorMessage = "Failed to update bookmark: \(error.localizedDescription)"
            }
        }
    }
    
    func selectCategory(_ category: String?) {
        selectedCategory = category
        loadArticles()
    }
}
