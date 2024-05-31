//
//  FeedItemsMapper.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 31/05/2024.
//


import Foundation


// MARK: - FeedItemsMapper
final class FeedItemsMapper {
    private static var OK_200: Int { return 200 }
    
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> IrradiancesFeed {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        return root.item
    }
    
    
    // MARK: - Root
    private struct Root: Decodable {
        let geometry: Geometry
        let properties: Properties
        
        var item: IrradiancesFeed {
            return IrradiancesFeed(geometry: geometry, properties: properties)
        }
    }
}
