//
//  MyNewsApp.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import SwiftUI
@main
struct MyNewsApp: App {
    let newsRepository: NewsRepositoryProtocol
    let storageManager: StorageManagerProtocol
    
    init() {
        let storageManager = CoreDataStorageManager()
        self.storageManager = storageManager
        
        let newsService = NewsService()
        newsRepository = NewsRepository(newsService: newsService, storageManager: storageManager)
    }
    
    var body: some Scene {
        WindowGroup {
            NewsListView(viewModel: NewsListViewModel(repository: newsRepository))
                .environment(\.managedObjectContext, (storageManager as! CoreDataStorageManager).persistentContainer.viewContext)
        }
    }
}
