//
//  URLSessionHTTPClient.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 05/06/2024.
//


import Foundation


public class URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession
    
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    
    public func get(from url: URL, completion: @escaping (HTTPClientProtocol.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
