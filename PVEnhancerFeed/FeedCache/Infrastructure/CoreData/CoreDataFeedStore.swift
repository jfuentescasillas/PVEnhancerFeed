//
//  CoreDataFeedStore.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 17/06/2024.
//


import CoreData


public final class CoreDataFeedStore: FeedStoreProtocol {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "IrradiancesFeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    
    // MARK: - Methods related to Retrieve data
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    if let localFeed = cache.localIrradiancesFeed {
                        completion(.success(CachedFeed(feed: localFeed, timestamp: cache.timestamp)))
                    } else {
                        completion(.success(.none))
                    }
                } else {
                    completion(.success(.none))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - Methods related to Insert data
    public func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.irradiancesFeed = NSOrderedSet(object: ManagedIrradiancesFeed.insert(feed, in: context))
                
                try context.save()
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    

    // MARK: - Methods related to Deletion of data
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
               
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    
    // MARK: - Custom Methods
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
