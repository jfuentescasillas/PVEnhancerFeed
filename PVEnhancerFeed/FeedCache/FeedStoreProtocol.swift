//
//  FeedStoreProtocol.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 07/06/2024.
//


import Foundation


public protocol FeedStoreProtocol {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ item: IrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion)
}
