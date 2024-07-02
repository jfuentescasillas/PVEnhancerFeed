//
//  CoreDataIrradiancesStore.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 17/06/2024.
//


import CoreData


public final class CoreDataIrradiancesStore: FeedStoreProtocol {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "IrradiancesFeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    
    // MARK: - Methods related to Retrieve data
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performRetrieval { result in
                completion(result)
            }
    }
    
    
    private func performRetrieval(completion: @escaping (Result<CachedFeed?, Error>) -> Void) {
        perform { (context: NSManagedObjectContext) in
            do {
                if let cache = try ManagedCache.find(in: context),
                   let managedFeed = cache.irradiancesFeed.firstObject as? ManagedIrradiancesFeed {
                    
                    // Convert coordinates string to array of doubles
                    let coordinates = managedFeed.geometry?.coordinates?.components(separatedBy: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) } ?? []
                    
                    // Retrieve parameters from ManagedParameter and convert to dictionaries
                    let dniDict = managedFeed.properties?.parameter?.allskySfcSwDni?.toDictionary()
                    let ghiDict = managedFeed.properties?.parameter?.allskySfcSwDwn?.toDictionary()
                    let dhiDict = managedFeed.properties?.parameter?.allskySfcSwDiff?.toDictionary()
                    
                    let parameter = Parameter(
                        allskySfcSwDni: dniDict,
                        allskySfcSwDwn: ghiDict,
                        allskySfcSwDiff: dhiDict
                    )
                    
                    let localFeed = LocalIrradiancesFeed(
                        geometry: Geometry(coordinates: coordinates),
                        properties: Properties(parameter: parameter)
                    )
                    
                    completion(.success(CachedFeed(feed: localFeed, timestamp: cache.timestamp)))
                } else {
                    completion(.success(nil))
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
                
                // Create an ordered set with the inserted ManagedIrradiancesFeed
                let managedFeed = ManagedIrradiancesFeed.insert(feed, in: context)
                let orderedSet = NSOrderedSet(object: managedFeed)
                
                // Assign the ordered set to managedCache.irradiancesFeed
                managedCache.irradiancesFeed = orderedSet
                
                try context.save()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    

    // MARK: - Methods related to Deletion of data
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
               
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - Custom Methods
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
