//
//  IrradiancesFeed.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 22/04/24.
//


import Foundation


// MARK: - IrradiancesNASA
public struct IrradiancesFeed: Codable, Equatable {
    let geometry: Geometry?
    let properties: Properties?
    
    
    public static func == (lhs: IrradiancesFeed, rhs: IrradiancesFeed) -> Bool {
        // Compare each property for equality
        let result: Bool = lhs.geometry == rhs.geometry && lhs.properties == rhs.properties
        
        return result
    }
}


// MARK: - Geometry
struct Geometry: Codable, Equatable {
    let coordinates: [Double]?
}


// MARK: - Properties
struct Properties: Codable, Equatable {
    let parameter: Parameter?
    
    
    public static func == (lhs: Properties, rhs: Properties) -> Bool {
        return lhs.parameter == rhs.parameter
    }
}


// MARK: - Parameter
struct Parameter: Codable, Equatable {
    let allskySfcSwDni: [String: Double]?
    let allskySfcSwDwn: [String: Double]?
    let allskySfcSwDiff: [String: Double]?
    

    enum CodingKeys: String, CodingKey {
        case allskySfcSwDni = "ALLSKY_SFC_SW_DNI"
        case allskySfcSwDwn = "ALLSKY_SFC_SW_DWN"
        case allskySfcSwDiff = "ALLSKY_SFC_SW_DIFF"
    }
}
