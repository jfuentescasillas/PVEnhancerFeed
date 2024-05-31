//
//  HTTPClient.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 31/05/2024.
//


import Foundation


public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}


// MARK: - HTTPClient Protocol
public protocol HTTPClientProtocol {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
