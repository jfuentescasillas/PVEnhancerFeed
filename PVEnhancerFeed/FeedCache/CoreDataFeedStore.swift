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
        let context = self.context
        context.perform {
            do {
                if let cache = try ManagedCache.find(in: context) {
                    if let localFeed = cache.localIrradiancesFeed {
                        completion(.found(feed: localFeed, timestamp: cache.timestamp))
                    } else {
                        completion(.empty)
                    }
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - Methods related to Insert data
    public func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
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
        let context = self.context
        context.perform {
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
               
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}


// MARK: - Extension. NSPersistentContainer
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


// MARK: - Extension. NSManagedObjectModel
private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}


// MARK: - Managed classes
@objc(ManagedCache)
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var irradiancesFeed: NSOrderedSet
    
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
    
        return try context.fetch(request).first
    }
    
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        if let existingCache = try find(in: context) {
            context.delete(existingCache)
        }
      
        return ManagedCache(context: context)
    }
    
    
    var localIrradiancesFeed: LocalIrradiancesFeed? {
        guard let managedFeed = irradiancesFeed.firstObject as? ManagedIrradiancesFeed else {
            return nil
        }
    
        return managedFeed.local
    }

    
    static func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, in context: NSManagedObjectContext) throws {
        let managedCache = ManagedCache(context: context)
        managedCache.timestamp = timestamp
        managedCache.irradiancesFeed = NSOrderedSet(object: ManagedIrradiancesFeed.insert(feed, in: context))
     
        try context.save()
    }
}


@objc(ManagedGeometry)
private class ManagedGeometry: NSManagedObject {
    @NSManaged var coordinates: String?
    @NSManaged var feed: ManagedIrradiancesFeed?
    
    var local: Geometry {
        let coordinatesArray = coordinates?.split(separator: ",").compactMap { Double($0) }
        
        return Geometry(coordinates: coordinatesArray)
    }
    
    
    static func insert(_ geometry: Geometry?, in context: NSManagedObjectContext) -> ManagedGeometry? {
        guard let geometry = geometry else {
            return nil
        }
        
        let managedGeometry = ManagedGeometry(context: context)
        managedGeometry.coordinates = geometry.coordinates?.map { String($0) }.joined(separator: ",")
        
        return managedGeometry
    }
}


@objc(ManagedIrradiancesFeed)
private class ManagedIrradiancesFeed: NSManagedObject {
    @NSManaged var cache: ManagedCache?
    @NSManaged var geometry: ManagedGeometry?
    @NSManaged var properties: ManagedProperties?
    
    var local: LocalIrradiancesFeed {
        let localIrrFeed = LocalIrradiancesFeed(
            geometry: geometry!.local,
            properties: properties!.local)
        
        return localIrrFeed
    }
    
    
    static func insert(_ feed: LocalIrradiancesFeed, in context: NSManagedObjectContext) -> ManagedIrradiancesFeed {
        let managedFeed = ManagedIrradiancesFeed(context: context)
        managedFeed.geometry = ManagedGeometry.insert(feed.geometry, in: context)
        managedFeed.properties = ManagedProperties.insert(feed.properties, in: context)
       
        return managedFeed
    }
}


@objc(ManagedParameter)
private class ManagedParameter: NSManagedObject {
    @NSManaged var allskySfcSwDiff: String?
    @NSManaged var allskySfcSwDni: String?
    @NSManaged var allskySfcSwDwn: String?
    @NSManaged var properties: ManagedProperties?
    
    var local: Parameter {
        let localParameter = Parameter(
            allskySfcSwDni: allskySfcSwDni?.toDictionary(),
            allskySfcSwDwn: allskySfcSwDwn?.toDictionary(),
            allskySfcSwDiff: allskySfcSwDiff?.toDictionary()
        )
        
        return localParameter
    }
    
    
    static func insert(_ parameter: Parameter?, in context: NSManagedObjectContext) -> ManagedParameter? {
        guard let parameter = parameter else {
            return nil
        }
        
        let managedParameter = ManagedParameter(context: context)
        managedParameter.allskySfcSwDni = parameter.allskySfcSwDni?.toString()
        managedParameter.allskySfcSwDwn = parameter.allskySfcSwDwn?.toString()
        managedParameter.allskySfcSwDiff = parameter.allskySfcSwDiff?.toString()
        
        return managedParameter
    }
}


@objc(ManagedProperties)
private class ManagedProperties: NSManagedObject {
    @NSManaged var feed: ManagedIrradiancesFeed?
    @NSManaged var parameter: ManagedParameter?
    
    var local: Properties {
        return Properties(parameter: parameter?.local)
    }
    
    
    static func insert(_ properties: Properties?, in context: NSManagedObjectContext) -> ManagedProperties? {
        guard let properties = properties else {
            return nil
        }
        
        let managedProperties = ManagedProperties(context: context)
        managedProperties.parameter = ManagedParameter.insert(properties.parameter, in: context)
        
        return managedProperties
    }
}


// MARK: - Extension. Dictionary
private extension Dictionary where Key == String, Value == Double {
    func toString() -> String {
        return self.map { "\($0.key):\($0.value)" }.joined(separator: ",")
    }
}


// MARK: - Extension. String
private extension String {
    func toDictionary() -> [String: Double]? {
        let pairs = self.split(separator: ",").map { $0.split(separator: ":") }
        var dictionary = [String: Double]()
      
        for pair in pairs {
            if pair.count == 2, let value = Double(pair[1]) {
                dictionary[String(pair[0])] = value
            }
        }
       
        return dictionary
    }
}
