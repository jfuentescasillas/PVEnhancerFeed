//
//  CoreDataFeedStore.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 17/06/2024.
//


import CoreData


public final class CoreDataFeedStore: FeedStoreProtocol {
    public init() {}
    

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    
    public func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion) {

    }
    

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }
}


private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var irradiancesFeed: NSOrderedSet
}


private class ManagedGeometry: NSManagedObject {
    @NSManaged var coordinates: String?
    @NSManaged var feed: ManagedIrradiancesFeed?
}


private class ManagedIrradiancesFeed: NSManagedObject {
    @NSManaged var cache: ManagedCache?
    @NSManaged var geometry: ManagedGeometry?
    @NSManaged var properties: ManagedProperties?
}


private class ManagedParameter: NSManagedObject {
    @NSManaged var allskySfcSwDiff: String?
    @NSManaged var allskySfcSwDni: String?
    @NSManaged var allskySfcSwDwn: String?
    @NSManaged var properties: ManagedProperties?
}


private class ManagedProperties: NSManagedObject {
    @NSManaged var feed: ManagedIrradiancesFeed?
    @NSManaged var parameter: ManagedParameter?
}
