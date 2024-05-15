//
//  IrradiancesFeedError.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 29/04/24.
//


import Foundation


struct IrradiancesFeedError: Codable {
    let header: String?
    let messages: [String]?
}
