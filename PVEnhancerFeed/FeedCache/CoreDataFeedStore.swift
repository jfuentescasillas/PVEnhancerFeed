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

    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context: NSManagedObjectContext = self.context
        context.perform {
            do {
                let request: NSFetchRequest<ManagedCache> = NSFetchRequest(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                
                let caches: [ManagedCache] = try context.fetch(request)
               
                if let cache = caches.first {
                    let irradiancesFeedSet: NSOrderedSet = cache.irradiancesFeed
                    let managedFeeds: [ManagedIrradiancesFeed] = irradiancesFeedSet.compactMap { $0 as? ManagedIrradiancesFeed }
                    
                    let localFeeds: [LocalIrradiancesFeed] = managedFeeds.map { managedFeed in
                        let geometry = Geometry(coordinates: managedFeed.geometry?.coordinates?.split(separator: ",").compactMap { Double($0) })
                        let parameter = Parameter(
                            allskySfcSwDiff: managedFeed.properties?.parameter?.allskySfcSwDiff,
                            allskySfcSwDni: managedFeed.properties?.parameter?.allskySfcSwDni,
                            allskySfcSwDwn: managedFeed.properties?.parameter?.allskySfcSwDwn
                        )
                        
                        let properties = Properties(parameter: parameter)
                       
                        return LocalIrradiancesFeed(geometry: geometry, properties: properties)
                    }
                    
                    completion(.found(feed: localFeeds, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    
    public func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion) {
        let context: NSManagedObjectContext = self.context
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                
                // Create ManagedIrradiancesFeed from LocalIrradiancesFeed
                let managedFeed = ManagedIrradiancesFeed(context: context)
                managedFeed.geometry = ManagedGeometry(context: context)
                
                // Convert coordinates to a comma-separated string
                if let coordinates = feed.geometry.coordinates {
                    managedFeed.geometry?.coordinates = coordinates.map { String($0) }.joined(separator: ",")
                } else {
                    managedFeed.geometry?.coordinates = nil
                }
                
                managedFeed.properties = ManagedProperties(context: context)
                managedFeed.properties?.parameter = ManagedParameter(context: context)
                managedFeed.properties?.parameter?.allskySfcSwDiff = feed.properties.parameter?.allskySfcSwDiff
                managedFeed.properties?.parameter?.allskySfcSwDni = feed.properties.parameter?.allskySfcSwDni
                managedFeed.properties?.parameter?.allskySfcSwDwn = feed.properties.parameter?.allskySfcSwDwn
                
                managedCache.irradiancesFeed = NSOrderedSet(array: [managedFeed])
                
                try context.save()
               
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }
}


private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
      
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}


private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}


@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var irradiancesFeed: NSOrderedSet
}


@objc(ManagedGeometry)
private class ManagedGeometry: NSManagedObject {
    @NSManaged var coordinates: String?
    @NSManaged var feed: ManagedIrradiancesFeed?
}


@objc(ManagedIrradiancesFeed)
private class ManagedIrradiancesFeed: NSManagedObject {
    @NSManaged var cache: ManagedCache?
    @NSManaged var geometry: ManagedGeometry?
    @NSManaged var properties: ManagedProperties?
}


@objc(ManagedParameter)
private class ManagedParameter: NSManagedObject {
    @NSManaged var allskySfcSwDiff: String?
    @NSManaged var allskySfcSwDni: String?
    @NSManaged var allskySfcSwDwn: String?
    @NSManaged var properties: ManagedProperties?
}


@objc(ManagedProperties)
private class ManagedProperties: NSManagedObject {
    @NSManaged var feed: ManagedIrradiancesFeed?
    @NSManaged var parameter: ManagedParameter?
}
