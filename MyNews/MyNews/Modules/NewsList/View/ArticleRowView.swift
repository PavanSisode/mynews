//
//  ArticleRowView.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import SwiftUI

struct ArticleRowView: View {
    let article: Article
    let toggleBookmark: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.headline)
            Text(article.description ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Spacer()
                Button(action: toggleBookmark) {
                    Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .padding(.vertical, 8)
    }
}
