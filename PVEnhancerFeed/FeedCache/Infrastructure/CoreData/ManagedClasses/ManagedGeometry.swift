//
//  ManagedGeometry.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 01/07/2024.
//


import CoreData


// MARK: - ManagedGeometry
@objc(ManagedGeometry)
class ManagedGeometry: NSManagedObject {
    @NSManaged var coordinates: String?
    @NSManaged var feed: ManagedIrradiancesFeed?
}


// MARK: - Extension
extension ManagedGeometry {
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
