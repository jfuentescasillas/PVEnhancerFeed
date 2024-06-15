//
//  LocalFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 07/06/2024.
//


import Foundation


// MARK: - Class. LocalFeedLoader
public final class LocalFeedLoader {
    private let store: FeedStoreProtocol
    private let currentDate: () -> Date
    
    
    public init(store: FeedStoreProtocol, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}


// MARK: - Extension. Save & Cache
extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
    
    public func save(_ item: IrradiancesFeed, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(item, with: completion)
            }
        }
    }
    
    
    private func cache(_ item: IrradiancesFeed, with completion: @escaping (SaveResult) -> Void) {
        store.insert(item.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}


// MARK: - Extension. Load
extension LocalFeedLoader: IrradiancesFeedLoaderProtocol {
    public typealias LoadResult = LoadIrradiancesFeedResult
    
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
                
            case let .found(feed, timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModel()))
                
            case .found, .empty:
                completion(.success(IrradiancesFeed(geometry: .empty, properties: .empty)))
            }
        }
    }
}


// MARK: - Extension. validateCache
extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .found(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
                
            case .empty, .found: break
            }
        }
    }
}
