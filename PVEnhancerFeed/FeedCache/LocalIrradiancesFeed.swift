//
//  LocalIrradiancesFeed.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 12/06/2024.
//


import Foundation


public struct LocalIrradiancesFeed: Equatable {
    public let geometry: Geometry
    public let properties: Properties

    
    public init(geometry: Geometry, properties: Properties) {
        self.geometry = geometry
        self.properties = properties
    }
}


public extension LocalIrradiancesFeed {
    func toModel() -> IrradiancesFeed {
        let model = IrradiancesFeed(
            geometry: Geometry(coordinates: self.geometry.coordinates),
            properties: Properties(parameter: Parameter(
                allskySfcSwDni: self.properties.parameter?.allskySfcSwDni,
                allskySfcSwDwn: self.properties.parameter?.allskySfcSwDwn,
                allskySfcSwDiff: self.properties.parameter?.allskySfcSwDiff
            ))
        )
        
        return model
    }
}
