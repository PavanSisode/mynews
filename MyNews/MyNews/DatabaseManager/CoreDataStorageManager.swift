//
//  CoreDataStorageManager.swift
//  MyNews
//
//  Created by Pavan Shisode on 13/10/24.
//

import Foundation
import CoreData
import Combine

public class CDArticle: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var summary: String?
    @NSManaged public var content: String?
    @NSManaged public var category: String?
    @NSManaged public var publishDate: Date?
    @NSManaged public var isBookmarked: Bool
}

extension CDArticle {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDArticle> {
        return NSFetchRequest<CDArticle>(entityName: "CDArticle")
    }
}

// MARK: - StorageManagerProtocol

protocol StorageManagerProtocol {
    func saveArticle(_ article: Article) throws
    func fetchBookmarkedArticles() throws -> [Article]
    func removeBookmark(for articleID: String) throws
    func isArticleBookmarked(_ articleID: String) -> Bool
}

// MARK: - CoreDataStorageManager

class CoreDataStorageManager: StorageManagerProtocol {
    
    let persistentContainer: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init(inMemory: Bool = false) {
        // Create a managed object model programmatically
        let managedObjectModel = NSManagedObjectModel()
        
        let entityDescription = NSEntityDescription()
        entityDescription.name = "CDArticle"
        entityDescription.managedObjectClassName = NSStringFromClass(CDArticle.self)
        
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .stringAttributeType
        
        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        
        let summaryAttribute = NSAttributeDescription()
        summaryAttribute.name = "summary"
        summaryAttribute.attributeType = .stringAttributeType
        
        let contentAttribute = NSAttributeDescription()
        contentAttribute.name = "content"
        contentAttribute.attributeType = .stringAttributeType
        
        let categoryAttribute = NSAttributeDescription()
        categoryAttribute.name = "category"
        categoryAttribute.attributeType = .stringAttributeType
        
        let publishDateAttribute = NSAttributeDescription()
        publishDateAttribute.name = "publishDate"
        publishDateAttribute.attributeType = .dateAttributeType
        
        let isBookmarkedAttribute = NSAttributeDescription()
        isBookmarkedAttribute.name = "isBookmarked"
        isBookmarkedAttribute.attributeType = .booleanAttributeType
        
        entityDescription.properties = [idAttribute, titleAttribute, summaryAttribute, contentAttribute, categoryAttribute, publishDateAttribute, isBookmarkedAttribute]
        
        managedObjectModel.entities = [entityDescription]
        
        // Create a persistent container with the programmatically created model
        persistentContainer = NSPersistentContainer(name: "NewsReader", managedObjectModel: managedObjectModel)
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    func saveArticle(_ article: Article) throws {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", article.id)
            
            do {
                let results = try self.backgroundContext.fetch(fetchRequest)
                let cdArticle: CDArticle
                
                if let existingArticle = results.first {
                    cdArticle = existingArticle
                } else {
                    cdArticle = CDArticle(context: self.backgroundContext)
                    cdArticle.id = article.id
                }
                
                cdArticle.title = article.title
                cdArticle.summary = article.description
                cdArticle.content = article.content
                cdArticle.category = article.title
                //                cdArticle.publishDate = article.publishedAt
                cdArticle.isBookmarked = true
                
                try self.backgroundContext.save()
            } catch {
                print("Failed to save article: \(error)")
            }
        }
    }
    
    func fetchBookmarkedArticles() throws -> [Article] {
        let fetchRequest: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == YES")
        
        do {
            let results = try backgroundContext.fetch(fetchRequest)
            return results.compactMap { self.convertToArticle($0) }
        } catch {
            throw error
        }
    }
    
    func removeBookmark(for articleID: String) throws {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@ AND isBookmarked == YES", articleID)
            
            do {
                let results = try self.backgroundContext.fetch(fetchRequest)
                if let articleToUnbookmark = results.first {
                    articleToUnbookmark.isBookmarked = false
                    try self.backgroundContext.save()
                }
            } catch {
                print("Failed to remove bookmark: \(error)")
            }
        }
    }
    
    func isArticleBookmarked(_ articleID: String) -> Bool {
        let fetchRequest: NSFetchRequest<CDArticle> = CDArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND isBookmarked == YES", articleID)
        
        do {
            let count = try backgroundContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check if article is bookmarked: \(error)")
            return false
        }
    }
    
    private func convertToArticle(_ cdArticle: CDArticle) -> Article? {
        guard let id = cdArticle.id else { return nil }
        
        return Article(id: id,
                       source: Source(id: "", name: ""),
                       author: "",
                       title: cdArticle.title ?? "",
                       description: cdArticle.summary,
                       urlToImage: "",
                       publishedAt: "publishDate",
                       content: cdArticle.content ?? "",
                       isBookmarked: cdArticle.isBookmarked)
    }
}
