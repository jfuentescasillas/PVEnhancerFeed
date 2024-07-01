//
//  ManagedClasses.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 01/07/2024.
//


import CoreData


// MARK: - Managed classes
@objc(ManagedCache)
class ManagedCache: NSManagedObject {
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
class ManagedGeometry: NSManagedObject {
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
class ManagedIrradiancesFeed: NSManagedObject {
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
class ManagedParameter: NSManagedObject {
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
class ManagedProperties: NSManagedObject {
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
