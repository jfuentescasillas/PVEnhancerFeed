//
//  IrradiancesFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 22/04/24.
//


import Foundation


// MARK: - LoadIrradiancesFeedResult 
public typealias LoadIrradiancesFeedResult = Result<IrradiancesFeed, Error>


// MARK: - IrradiancesFeedLoader Protocol
public protocol IrradiancesFeedLoaderProtocol {
    func load(completion: @escaping (LoadIrradiancesFeedResult) -> Void)
}
