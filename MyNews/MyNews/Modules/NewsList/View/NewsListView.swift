//
//  NewsListView.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//


import SwiftUI
struct NewsListView: View {
    @StateObject var viewModel: NewsListViewModel
    @State private var showingBookmarks = false
    
    let categories = ["Business", "Entertainment", "General", "Health", "Science", "Sports", "Technology"]
    
    var body: some View {
        NavigationView {
            VStack {
                categoryPicker
                
                if showingBookmarks {
                    bookmarkedArticlesList
                } else {
                    articlesList
                }
            }
            .navigationTitle("News")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(showingBookmarks ? "Show All" : "Bookmarks") {
                        showingBookmarks.toggle()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadArticles()
            viewModel.loadBookmarkedArticles()
        }
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button("All") {
                    viewModel.selectCategory(nil)
                }
                .buttonStyle(.bordered)
                .tint(viewModel.selectedCategory == nil ? .blue : .gray)
                
                ForEach(categories, id: \.self) { category in
                    Button(category) {
                        viewModel.selectCategory(category)
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.selectedCategory == category ? .blue : .gray)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var articlesList: some View {
        List {
            ForEach(viewModel.articles) { article in
                ArticleRowView(article: article, toggleBookmark: {
                    viewModel.toggleBookmark(for: article)
                })
            }
        }
        .overlay(Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        })
        .refreshable {
            viewModel.loadArticles()
        }
    }
    
    private var bookmarkedArticlesList: some View {
        List {
            ForEach(viewModel.bookmarkedArticles) { article in
                ArticleRowView(article: article, toggleBookmark: {
                    viewModel.toggleBookmark(for: article)
                })
            }
        }
        .overlay(Group {
            if viewModel.bookmarkedArticles.isEmpty {
                Text("No bookmarked articles")
                    .foregroundColor(.gray)
            }
        })
        .refreshable {
            viewModel.loadBookmarkedArticles()
        }
    }
}

/*
struct NewsListView: View {
    @StateObject var viewModel: NewsListViewModel
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List(viewModel.articles) { article in
                NavigationLink(value: article) {
                    ArticleRowView(article: article)
                }
            }
            .navigationTitle("News")
            .navigationDestination(for: Article.self) { article in
                ArticleDetailView(viewModel: ArticleDetailViewModel(article: article, repository: viewModel.repository))
            }
            .toolbar {
                Menu("Category") {
                    Button("All") { viewModel.setCategory(nil) }
                    Button("Technology") { viewModel.setCategory("technology") }
                    Button("Sports") { viewModel.setCategory("sports") }
                    // Add more categories
                }
            }
        }
        .task {
            await viewModel.fetchNews()
        }
    }
}
*/
