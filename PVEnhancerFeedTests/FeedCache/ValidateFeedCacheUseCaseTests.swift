//
//  ValidateFeedCacheUseCaseTests.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 13/06/2024.
//



import XCTest
import PVEnhancerFeed


class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedIrradiances, [])
    }
    
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve, .deleteCachedFeed])
    }
    
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    func test_validateCache_deletesCacheOnExpiration() {
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve, .deleteCachedFeed])
    }
    
    
    func test_validateCache_deletesExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve, .deleteCachedFeed])
    }
    
    
    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        sut?.validateCache()
        
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
}
