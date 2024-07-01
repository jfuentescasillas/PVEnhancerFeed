//
//  RemoteFeedLoader.swift
//  PVEnhancerFeed
//
//  Created by jfuentescasillas on 23/04/24.
//


import Foundation


// MARK: - RemoteFeedLoader Class
public class RemoteFeedLoader: IrradiancesFeedLoaderProtocol {
    private let url: URL
    private let client: HTTPClientProtocol
        
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    
    public typealias Result = IrradiancesFeedLoaderProtocol.Result
    
    
    public init(url: URL, client: HTTPClientProtocol) {
        self.url = url
        self.client = client
    }
    
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data, from: response))
           
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try FeedItemsMapper.map(data, from: response)
         
            return .success(item.toModel())
        } catch {
            return .failure(error)
        }
    }
}
