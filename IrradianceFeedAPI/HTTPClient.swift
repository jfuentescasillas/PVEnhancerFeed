//
//  HTTPClient.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 31/05/2024.
//


import Foundation


// MARK: - HTTPClient Protocol
public protocol HTTPClientProtocol {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}
