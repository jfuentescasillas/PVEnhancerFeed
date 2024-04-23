//
//  PVEnhancerFeedTests.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 23/04/24.
//


import XCTest


// MARK: - RemoteFeedLoader Class
class RemoteFeedLoader {
    let url: URL
    let client: HTTPClientProtocol
        
    
    init(url: URL, client: HTTPClientProtocol) {
        self.url = url
        self.client = client
    }
    
    
    func load() {
        client.get(from: url)
    }
}


// MARK: - HTTPClient Protocol
protocol HTTPClientProtocol {
    func get(from url: URL)
}


// MARK: - PVEnhancerFeedTests Class
final class PVEnhancerFeedTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    
    private class HTTPClientSpy: HTTPClientProtocol {
        var requestedURL: URL?
        
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}
