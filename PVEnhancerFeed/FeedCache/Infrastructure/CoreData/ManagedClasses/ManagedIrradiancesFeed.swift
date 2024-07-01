//
//  ManagedIrradiancesFeed.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 01/07/2024.
//


import CoreData


// MARK: - ManagedIrradiancesFeed
@objc(ManagedIrradiancesFeed)
class ManagedIrradiancesFeed: NSManagedObject {
    @NSManaged var cache: ManagedCache?
    @NSManaged var geometry: ManagedGeometry?
    @NSManaged var properties: ManagedProperties?
}
 

// MARK: - Extension
extension ManagedIrradiancesFeed {
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
