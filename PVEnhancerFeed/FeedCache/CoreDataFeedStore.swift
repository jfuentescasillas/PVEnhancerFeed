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
            CoreDataFeedStore.retrieveData(context: context, completion: completion)
        }
    }

    
    private static func retrieveData(context: NSManagedObjectContext, completion: @escaping RetrievalCompletion) {
        do {
            let request: NSFetchRequest<ManagedCache> = NSFetchRequest(entityName: ManagedCache.entity().name!)
            request.returnsObjectsAsFaults = false
            
            let caches: [ManagedCache] = try context.fetch(request)
            
            if let cache = caches.first {
                let irradiancesFeedSet: NSOrderedSet = cache.irradiancesFeed
                
                if let managedFeed = irradiancesFeedSet.firstObject as? ManagedIrradiancesFeed {
                    let localFeed = CoreDataFeedStore.mapToLocalFeed(managedFeed: managedFeed)
                   
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
    
    
    private static func mapToLocalFeed(managedFeed: ManagedIrradiancesFeed) -> LocalIrradiancesFeed {
        let coordinates: [Double]? = managedFeed.geometry?.coordinates?.split(separator: ",").compactMap { Double($0) }
        
        let allskySfcSwDni: [String: Double]? = managedFeed.properties?.parameter?.allskySfcSwDni?.split(separator: ",").reduce(into: [String: Double]()) { dict, entry in
            let keyValue = entry.split(separator: ":")
            
            if keyValue.count == 2, let key = keyValue.first, let value = Double(keyValue.last!) {
                dict[String(key)] = value
            }
        }
        
        let allskySfcSwDwn: [String: Double]? = managedFeed.properties?.parameter?.allskySfcSwDwn?.split(separator: ",").reduce(into: [String: Double]()) { dict, entry in
            let keyValue = entry.split(separator: ":")
           
            if keyValue.count == 2, let key = keyValue.first, let value = Double(keyValue.last!) {
                dict[String(key)] = value
            }
        }
        
        let allskySfcSwDiff: [String: Double]? = managedFeed.properties?.parameter?.allskySfcSwDiff?.split(separator: ",").reduce(into: [String: Double]()) { dict, entry in
            let keyValue = entry.split(separator: ":")
           
            if keyValue.count == 2, let key = keyValue.first, let value = Double(keyValue.last!) {
                dict[String(key)] = value
            }
        }
        
        let parameter: Parameter = Parameter(
            allskySfcSwDni: allskySfcSwDni,
            allskySfcSwDwn: allskySfcSwDwn,
            allskySfcSwDiff: allskySfcSwDiff)
        let properties: Properties = Properties(parameter: parameter)
        let geometry: Geometry = Geometry(coordinates: coordinates)
        
        return LocalIrradiancesFeed(geometry: geometry, properties: properties)
    }
    
    
    private static func parseStringToDictionary(_ string: String?) -> [String: Double]? {
        guard let string else { return nil }
        
        let keyValuePairs = string.split(separator: ",").compactMap { pair -> (String, Double)? in
            let components = pair.split(separator: ":")
           
            if components.count == 2,
               let key = components.first?.trimmingCharacters(in: .whitespaces),
               let valueString = components.last?.trimmingCharacters(in: .whitespaces),
               let value = Double(valueString) {
                return (key, value)
            }
            
            return nil
        }
        
        return Dictionary(uniqueKeysWithValues: keyValuePairs)
    }
    
    
    public func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion) {
        let context: NSManagedObjectContext = self.context
        context.perform {
            do {
                let request: NSFetchRequest<ManagedCache> = NSFetchRequest(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false

                // Delete existing cache
                if let existingCache = try context.fetch(request).first {
                    context.delete(existingCache)
                }

                // Create new cache
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                
                // Map LocalIrradiancesFeed to ManagedIrradiancesFeed
                let managedFeed = ManagedIrradiancesFeed(context: context)
                
                // Mapping geometry
                let managedGeometry = ManagedGeometry(context: context)
                managedGeometry.coordinates = feed.geometry.coordinates?.map { String($0) }.joined(separator: ",")
                managedFeed.geometry = managedGeometry
                
                // Mapping properties and parameter
                let managedProperties = ManagedProperties(context: context)
                let managedParameter = ManagedParameter(context: context)
                
                managedParameter.allskySfcSwDiff = feed.properties.parameter?.allskySfcSwDiff?.map { "\($0.key):\($0.value)" }.joined(separator: ",")
                managedParameter.allskySfcSwDni = feed.properties.parameter?.allskySfcSwDni?.map { "\($0.key):\($0.value)" }.joined(separator: ",")
                managedParameter.allskySfcSwDwn = feed.properties.parameter?.allskySfcSwDwn?.map { "\($0.key):\($0.value)" }.joined(separator: ",")
                
                managedProperties.parameter = managedParameter
                managedFeed.properties = managedProperties
                
                managedCache.irradiancesFeed = NSOrderedSet(object: managedFeed)
                
                // Save context
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
