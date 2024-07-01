//
//  IrradiancesFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 22/04/24.
//


import Foundation


// MARK: - IrradiancesFeedLoader Protocol
public protocol IrradiancesFeedLoaderProtocol {
    typealias Result = Swift.Result<IrradiancesFeed, Error>
    
    func load(completion: @escaping (Result) -> Void)
}
