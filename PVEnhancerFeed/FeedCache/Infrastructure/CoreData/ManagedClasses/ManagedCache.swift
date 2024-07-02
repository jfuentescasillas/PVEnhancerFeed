//
//  ManagedCache.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 01/07/2024.
//


import CoreData


// MARK: - ManagedCache
@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var irradiancesFeed: NSOrderedSet
}


// MARK: - Extension
extension ManagedCache {
    var localIrradiancesFeed: LocalIrradiancesFeed? {
        guard let managedFeed = irradiancesFeed.firstObject as? ManagedIrradiancesFeed else {
            return nil
        }
    
        return managedFeed.local
    }

    
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
    
    
    static func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, in context: NSManagedObjectContext) throws {
        let managedCache = ManagedCache(context: context)
        managedCache.timestamp = timestamp
        managedCache.irradiancesFeed = NSOrderedSet(object: ManagedIrradiancesFeed.insert(feed, in: context))
     
        try context.save()
    }
}
