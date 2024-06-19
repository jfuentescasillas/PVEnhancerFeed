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
    
    
    public init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "IrradiancesFeedStore", in: bundle)
        context = container.newBackgroundContext()
    }

    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    
    public func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion) {

    }
    

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }
}


private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    
    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
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
