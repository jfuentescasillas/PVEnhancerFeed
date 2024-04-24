//
//  RemoteFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 23/04/24.
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


// MARK: - RemoteFeedLoader Class
public class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClientProtocol
        
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    
    public init(url: URL, client: HTTPClientProtocol) {
        self.url = url
        self.client = client
    }
    
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
                
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
