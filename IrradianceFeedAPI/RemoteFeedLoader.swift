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
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                do {
                    let item = try FeedItemsMapper.map(data, response)
                    completion(.success(item))
                } catch {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}


// MARK: - FeedItemsMapper
private class FeedItemsMapper {
    static var OK_200: Int { return 200 }
    
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> IrradiancesFeed {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        return root.item
    }
    
    
    // MARK: - Root
    private struct Root: Decodable {
        let geometry: Geometry
        let properties: Properties
        
        var item: IrradiancesFeed {
            return IrradiancesFeed(geometry: geometry, properties: properties)
        }
    }
}
