//
//  RemoteFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 23/04/24.
//


import Foundation


// MARK: - RemoteFeedLoader Class
public class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClientProtocol
        
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    
    public enum Result: Equatable {
        case success(IrradiancesFeed)
        case failure(Error)
    }
    
    
    public init(url: URL, client: HTTPClientProtocol) {
        self.url = url
        self.client = client
    }
    
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(data, response):
                completion(self.map(data, from: response))
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try FeedItemsMapper.map(data, response)
             return .success(item)
        } catch {
            return .failure(.invalidData)
        }
    }
}
