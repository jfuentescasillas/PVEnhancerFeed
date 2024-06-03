//
//  IrradiancesFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 22/04/24.
//


import Foundation


// MARK: - LoadIrradiancesFeedResult Enum
public enum LoadIrradiancesFeedResult<Error: Swift.Error> {
    case success(IrradiancesFeed)
    case failure(Error)
}


// MARK: - IrradiancesFeedLoader Protocol
protocol IrradiancesFeedLoaderProtocol {
    associatedtype Error: Swift.Error

    func load(completion: @escaping (LoadIrradiancesFeedResult<Error>) -> Void)
}
