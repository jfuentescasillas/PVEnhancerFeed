//
//  RemoteFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 23/04/24.
//


import Foundation


// MARK: - HTTPClient Protocol
public protocol HTTPClientProtocol {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}


// MARK: - RemoteFeedLoader Class
public class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClientProtocol
        
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    
    public init(url: URL, client: HTTPClientProtocol) {
        self.url = url
        self.client = client
    }
    
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
