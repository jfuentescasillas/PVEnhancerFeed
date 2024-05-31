//
//  FeedItemsMapper.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 31/05/2024.
//


import Foundation


// MARK: - FeedItemsMapper
final class FeedItemsMapper {
    // MARK: - Root
    private struct Root: Decodable {
        let geometry: Geometry
        let properties: Properties
        
        var item: IrradiancesFeed {
            return IrradiancesFeed(geometry: geometry, properties: properties)
        }
    }
    
    
    private static var OK_200: Int { return 200 }
    
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            
            return .failure(.invalidData)
        }
        
        return .success(root.item)
    }
}
