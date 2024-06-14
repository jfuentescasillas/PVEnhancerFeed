//
//  CodableFeedStoreTests.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 14/06/2024.
//


import XCTest
import PVEnhancerFeed


// MARK: - Class CodableFeedStore
class CodableFeedStore {
    private struct Cache: Codable {
        let feed: CodableIrradiancesFeed
        let timestamp: Date
        
        var localFeed: LocalIrradiancesFeed {
            return feed.local
        }
    }
    
    
    private struct CodableIrradiancesFeed: Codable {
        private let geometry: Geometry
        private let properties: Properties
        
        
        init(_ feed: LocalIrradiancesFeed) {
            self.geometry = feed.geometry
            self.properties = feed.properties
        }
        
        
        var local: LocalIrradiancesFeed {
            return LocalIrradiancesFeed(geometry: geometry, properties: properties)
        }
    }
    
    
    private let storeURL: URL
    
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    
    func retrieve(completion: @escaping FeedStoreProtocol.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
         
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    
    func insert(_ feed: LocalIrradiancesFeed, timestamp: Date, completion: @escaping FeedStoreProtocol.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: CodableIrradiancesFeed(feed), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        
        try! encoded.write(to: storeURL)
        
        completion(nil)
    }
}


// MARK: - Class CodableFeedStoreTests
class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        // Given
        let sut = makeSUT()
        let feed = uniqueIrradiancesFeed().local
        let timestamp = Date()
        
        // Then
        insert((feed, timestamp), to: sut)
        
        // Assert
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        // Given
        let sut = makeSUT()
        let feed = uniqueIrradiancesFeed().local
        let timestamp = Date()
        
        // Then
        insert((feed, timestamp), to: sut)
        
        // Assert
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }


    func test_retrieve_deliversFailureOnRetrievalError() {
        let sut = makeSUT()
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    
    // - MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }

    
    private func insert(_ cache: (feed: LocalIrradiancesFeed, timestamp: Date), to sut: CodableFeedStore) {
        let exp = expectation(description: "Wait for cache insertion")
       
        sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
