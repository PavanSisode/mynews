//
//  ArticleDetailViewModel.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import Foundation

class ArticleDetailViewModel: ObservableObject {
    @Published var article: Article
    private let repository: NewsRepositoryProtocol
    
    init(article: Article, repository: NewsRepositoryProtocol) {
        self.article = article
        self.repository = repository
    }
    
    func toggleBookmark() {
        do {
            if article.isBookmarked {
                try repository.unbookmarkArticle(article)
            } else {
                try repository.bookmarkArticle(article)
            }
            article.isBookmarked.toggle()
        } catch {
//             Handle error
        }
    }
}
