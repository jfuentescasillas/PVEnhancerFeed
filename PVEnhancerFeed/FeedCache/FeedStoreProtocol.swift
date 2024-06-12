//
//  FeedStoreProtocol.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 07/06/2024.
//


import Foundation


// MARK: - FeedStoreProtocol
public protocol FeedStoreProtocol {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ item: LocalIrradiancesFeedItem, timestamp: Date, completion: @escaping InsertionCompletion)
}


// MARK: - LocalIrradiancesFeedItem
public struct LocalIrradiancesFeedItem: Equatable {
    public let geometry: Geometry
    public let properties: Properties

    
    public init(geometry: Geometry, properties: Properties) {
        self.geometry = geometry
        self.properties = properties
    }
}
