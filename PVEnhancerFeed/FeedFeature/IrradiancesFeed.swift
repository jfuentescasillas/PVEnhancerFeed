//
//  IrradiancesFeed.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 22/04/24.
//


import Foundation


// MARK: - IrradiancesNASA
public struct IrradiancesFeed: Equatable {
    public let geometry: Geometry
    public let properties: Properties
    
    
    public init(geometry: Geometry, properties: Properties) {
        self.geometry = geometry
        self.properties = properties
    }
}


public extension IrradiancesFeed {
    func toLocal() -> LocalIrradiancesFeed {
        return LocalIrradiancesFeed(geometry: geometry, properties: properties)
    }
}


// MARK: - Geometry
public struct Geometry: Decodable, Equatable {
    let coordinates: [Double]?
    
    
    public init(coordinates: [Double]?) {
        self.coordinates = coordinates
    }
    
    
    public static var empty: Geometry {
        return Geometry(coordinates: [])
    }
}


// MARK: - Properties
public struct Properties: Decodable, Equatable {
    let parameter: Parameter?
    
    
    public init(parameter: Parameter?) {
        self.parameter = parameter
    }
    
    
    public static var empty: Properties {
        return Properties(parameter: Parameter.empty)
    }
}


// MARK: - Parameter
public struct Parameter: Decodable, Equatable {
    let allskySfcSwDni: [String: Double]?
    let allskySfcSwDwn: [String: Double]?
    let allskySfcSwDiff: [String: Double]?
    
    
    public init(allskySfcSwDni: [String : Double]?, allskySfcSwDwn: [String : Double]?, allskySfcSwDiff: [String : Double]?) {
        self.allskySfcSwDni = allskySfcSwDni
        self.allskySfcSwDwn = allskySfcSwDwn
        self.allskySfcSwDiff = allskySfcSwDiff
    }
    
    
    enum CodingKeys: String, CodingKey {
        case allskySfcSwDni = "ALLSKY_SFC_SW_DNI"
        case allskySfcSwDwn = "ALLSKY_SFC_SW_DWN"
        case allskySfcSwDiff = "ALLSKY_SFC_SW_DIFF"
    }
    
    
    public static var empty: Parameter {
        return Parameter(allskySfcSwDni: [:], allskySfcSwDwn: [:], allskySfcSwDiff: [:])
    }
}
