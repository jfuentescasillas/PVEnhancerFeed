//
//  IrradiancesFeed.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 22/04/24.
//


import Foundation


// MARK: - IrradiancesNASA
struct IrradiancesFeed: Codable {
    let geometry: Geometry?
    let properties: Properties?
}


// MARK: - Geometry
struct Geometry: Codable {
    let coordinates: [Double]?
}


// MARK: - Properties
struct Properties: Codable {
    let parameter: Parameter?
}


// MARK: - Parameter
struct Parameter: Codable {
    let allskySfcSwDni: [String: Double]?
    let allskySfcSwDwn: [String: Double]?
    let allskySfcSwDiff: [String: Double]?
    

    enum CodingKeys: String, CodingKey {
        case allskySfcSwDni = "ALLSKY_SFC_SW_DNI"
        case allskySfcSwDwn = "ALLSKY_SFC_SW_DWN"
        case allskySfcSwDiff = "ALLSKY_SFC_SW_DIFF"
    }
}
