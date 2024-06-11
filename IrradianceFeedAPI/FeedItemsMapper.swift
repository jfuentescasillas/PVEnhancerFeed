//
//  FeedItemsMapper.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 31/05/2024.
//


import Foundation


// MARK: - RemoteIrradiancesFeedItem
struct RemoteIrradiancesFeedItem: Decodable {
    let geometry: RemoteGeometry
    let properties: RemoteProperties
    
    
    struct RemoteGeometry: Decodable {
        let coordinates: [Double]
    }
    
    
    struct RemoteProperties: Decodable {
        let parameter: RemoteParameter
    }
    
    
    struct RemoteParameter: Decodable {
        let allskySfcSwDni: [String: Double]
        let allskySfcSwDwn: [String: Double]
        let allskySfcSwDiff: [String: Double]
        
        
        enum CodingKeys: String, CodingKey {
            case allskySfcSwDni = "ALLSKY_SFC_SW_DNI"
            case allskySfcSwDwn = "ALLSKY_SFC_SW_DWN"
            case allskySfcSwDiff = "ALLSKY_SFC_SW_DIFF"
        }
    }
}


// MARK: - FeedItemsMapper
final class FeedItemsMapper {
    private struct Root: Decodable {
        let type: String
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


extension RemoteIrradiancesFeedItem {
    func toModel() -> IrradiancesFeed {
        let model = IrradiancesFeed(
            geometry: Geometry(coordinates: self.geometry.coordinates),
            properties: Properties(parameter: Parameter(
                allskySfcSwDni: self.properties.parameter.allskySfcSwDni,
                allskySfcSwDwn: self.properties.parameter.allskySfcSwDwn,
                allskySfcSwDiff: self.properties.parameter.allskySfcSwDiff
            ))
        )
        
        return model
    }
}
