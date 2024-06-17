//
//  CoreDataFeedStore.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 17/06/2024.
//


import Foundation


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
