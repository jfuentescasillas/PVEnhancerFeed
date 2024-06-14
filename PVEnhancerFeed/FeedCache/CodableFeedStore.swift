//
//  CodableFeedStore.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 14/06/2024.
//


import Foundation


public class CodableFeedStore: FeedStoreProtocol {
    private struct Cache: Codable {
        let feed: CodableIrradiancesFeed
        let timestamp: Date
        
        var localFeed: LocalIrradiancesFeed {
            return feed.local
        }
    }
    
    
    private struct CodableIrradiancesFeed: Codable {
        private let geometry: Geometry
        private let properties: Properties
        
        
        public init(_ feed: LocalIrradiancesFeed) {
            self.geometry = feed.geometry
            self.properties = feed.properties
        }
        
        
        var local: LocalIrradiancesFeed {
            return LocalIrradiancesFeed(geometry: geometry, properties: properties)
        }
    }
    
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated)
    private let storeURL: URL
    
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
       
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            do {
                let decoder = JSONDecoder()
                let cache = try decoder.decode(Cache.self, from: data)
                
                completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    
    public func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        
        queue.async {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(feed: CodableIrradiancesFeed(feed), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                
                try encoded.write(to: storeURL)
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
       
        queue.async {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
