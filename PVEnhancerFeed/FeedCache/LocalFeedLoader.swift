//
//  LocalFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 07/06/2024.
//


import Foundation


// MARK: - LocalFeedLoader
public final class LocalFeedLoader {
    private let store: FeedStoreProtocol
    private let currentDate: () -> Date
    
    
    public init(store: FeedStoreProtocol, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    
    public func save(_ item: IrradiancesFeed, completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(item, with: completion)
            }
        }
    }
    
    
    private func cache(_ item: IrradiancesFeed, with completion: @escaping (Error?) -> Void) {
        store.insert(item, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }

            completion(error)
        }
    }
}


// MARK: - FeedStoreProtocol
public protocol FeedStoreProtocol {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ item: IrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion)
}
