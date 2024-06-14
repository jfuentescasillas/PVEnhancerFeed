//
//  FeedItemsMapper.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 31/05/2024.
//


import Foundation


// MARK: - FeedItemsMapper
final class FeedItemsMapper {
    private struct Root: Decodable {
        let geometry: RemoteIrradiancesFeedItem.RemoteGeometry
        let properties: RemoteIrradiancesFeedItem.RemoteProperties
    }
    
    
    private static var OK_200: Int { return 200 }
    
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteIrradiancesFeedItem {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return RemoteIrradiancesFeedItem(geometry: root.geometry, properties: root.properties)
    }
}
