//
//  PVEnhancerFeedCacheIntegrationTests.swift
//  PVEnhancerFeedCacheIntegrationTests
//
//  Created by jfuentescasillas on 01/07/2024.
//


import XCTest
import PVEnhancerFeed


final class PVEnhancerFeedCacheIntegrationTests: XCTestCase {
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(irradiancesFeed):
                XCTAssertTrue(irradiancesFeed.geometry.coordinates?.isEmpty ?? true, "Expected empty coordinates")
                XCTAssertTrue(irradiancesFeed.properties.parameter?.allskySfcSwDni?.isEmpty ?? true, "Expected empty allskySfcSwDni")
                XCTAssertTrue(irradiancesFeed.properties.parameter?.allskySfcSwDwn?.isEmpty ?? true, "Expected empty allskySfcSwDwn")
                XCTAssertTrue(irradiancesFeed.properties.parameter?.allskySfcSwDiff?.isEmpty ?? true, "Expected empty allskySfcSwDiff")

            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
                        
            @unknown default:
                XCTFail("Received an unknown result")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
        
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
