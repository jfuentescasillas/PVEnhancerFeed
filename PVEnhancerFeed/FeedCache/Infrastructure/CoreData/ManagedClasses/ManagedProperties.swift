//
//  ManagedProperties.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 01/07/2024.
//


import CoreData


// MARK: - ManagedProperties
@objc(ManagedProperties)
class ManagedProperties: NSManagedObject {
    @NSManaged var feed: ManagedIrradiancesFeed?
    @NSManaged var parameter: ManagedParameter?
}


// MARK: - Extension
extension ManagedProperties {
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
