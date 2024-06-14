//
//  RemoteIrradiancesFeedItem.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 12/06/2024.
//


import Foundation


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


