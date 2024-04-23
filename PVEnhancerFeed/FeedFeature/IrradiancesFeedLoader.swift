//
//  IrradiancesFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 22/04/24.
//


import Foundation


// MARK: - LoadIrradiancesFeedResult Enum
enum LoadIrradiancesFeedResult {
    case success([IrradiancesFeed])
    case error(Error)
}


// MARK: - IrradiancesFeedLoader Protocol
protocol IrradiancesFeedLoaderProtocol {
    func load(completion: @escaping (LoadIrradiancesFeedResult) -> Void)
}
