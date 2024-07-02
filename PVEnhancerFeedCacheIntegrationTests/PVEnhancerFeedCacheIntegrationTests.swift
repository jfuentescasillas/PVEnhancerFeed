//
//  PVEnhancerFeedCacheIntegrationTests.swift
//  PVEnhancerFeedCacheIntegrationTests
//
//  Created by jfuentescasillas on 01/07/2024.
//


import XCTest
import PVEnhancerFeed


final class PVEnhancerFeedCacheIntegrationTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    
    func test_loadFeed_deliversNoItemsOnEmptyCache() throws {
        let feedLoader = try makeFeedLoader()
        
        expect(feedLoader, toLoad: IrradiancesFeed(
            geometry: Geometry(coordinates: []),
            properties: Properties(
                parameter: Parameter(
                    allskySfcSwDni: [:],
                    allskySfcSwDwn: [:],
                    allskySfcSwDiff: [:]
                )
            )
        ))
    }
        
    
    func test_loadFeed_deliversItemsSavedOnASeparateInstance() throws {
        let feedLoaderToPerformSave = try makeFeedLoader()
        let feedLoaderToPerformLoad = try makeFeedLoader()
        let feed = uniqueIrradiancesFeed().model
        
        save(feed, with: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() throws {
        let feedLoaderToPerformFirstSave = try makeFeedLoader()
        let feedLoaderToPerformLastSave = try makeFeedLoader()
        let feedLoaderToPerformLoad = try makeFeedLoader()
        let firstFeed = uniqueIrradiancesFeed().model
        let latestFeed = uniqueIrradiancesFeed().model
        
        save(firstFeed, with: feedLoaderToPerformFirstSave)
        save(latestFeed, with: feedLoaderToPerformLastSave)
        
        expect(feedLoaderToPerformLoad, toLoad: latestFeed)
    }
    
    
    // MARK: Helpers
    private func makeFeedLoader(file: StaticString = #filePath, line: UInt = #line) throws -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataIrradiancesStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try CoreDataIrradiancesStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    
    private func save(_ feed: IrradiancesFeed, with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save feed successfully", file: file, line: line)
            }
                    
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1)
    }
    
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: IrradiancesFeed, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { loadResult in
            switch loadResult {
            case let .success(loadedIrradianceFeed):
                XCTAssertEqual(loadedIrradianceFeed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
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
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
