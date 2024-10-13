//
//  ArticleDetailView.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import SwiftUI

struct ArticleDetailView: View {
    @ObservedObject var viewModel: ArticleDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.article.title)
                    .font(.title)
                Text(viewModel.article.content ?? "")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Article")
        .toolbar {
            Button(action: viewModel.toggleBookmark) {
                Image(systemName: viewModel.article.isBookmarked ? "bookmark.fill" : "bookmark")

            }
        }
    }
}
