//
//  LoadFeedFromCacheUseCaseTests.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 13/06/2024.
//


import XCTest
import PVEnhancerFeed


class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedIrradiances, [])
    }
    
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    
    func test_load_deliversNoIrradiancesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(IrradiancesFeed(geometry: .empty, properties: .empty)), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    
    func test_load_deliversCachedIrradiancesOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(uniqueIrradiancesFeed().model), when: {
            store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: nonExpiredTimestamp)
        })
    }
    
    
    func test_load_deliversNoIrradiancesOnCacheExpiration() {
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(IrradiancesFeed(geometry: .empty, properties: .empty)), when: {
            store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: expirationTimestamp)
        })
    }
    
    
    func test_load_deliversNoIrradiancesOnExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(IrradiancesFeed(geometry: .empty, properties: .empty)), when: {
            store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: expiredTimestamp)
        })
    }
    
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    func test_load_hasNoSideEffectsOnMoreThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.load { _ in }
        store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedIrradiances, [.retrieve])
    }
    
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.LoadResult]()
        
        sut?.load { receivedResults.append($0) }
               
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: lessThanSevenDaysOldTimestamp)
        
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
    
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedIrradiances), .success(expectedIrradiances)):
                XCTAssertEqual(receivedIrradiances, expectedIrradiances, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
       
        wait(for: [exp], timeout: 1)
    }
}
