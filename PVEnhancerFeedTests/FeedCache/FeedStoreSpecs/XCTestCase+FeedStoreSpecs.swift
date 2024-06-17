//
//  XCTestCase+FeedStoreSpecs.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 17/06/2024.
//

import XCTest
import PVEnhancerFeed


extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .empty, file: file, line: line)
    }
    

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueIrradiancesFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }

    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueIrradiancesFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }

    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert((uniqueIrradiancesFeed().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueIrradiancesFeed().local, Date()), to: sut)

        let insertionError = insert((uniqueIrradiancesFeed().local, Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }

    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueIrradiancesFeed().local, Date()), to: sut)

        let latestFeed = uniqueIrradiancesFeed().local
        let latestTimestamp = Date()
       
        insert((latestFeed, latestTimestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
    }
    

    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }
    

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueIrradiancesFeed().local, Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }

    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueIrradiancesFeed().local, Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    

    func assertThatSideEffectsRunSerially(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueIrradiancesFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueIrradiancesFeed().local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5)

        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
    }
}


extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: LocalIrradiancesFeed, timestamp: Date), to sut: FeedStoreProtocol) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return insertionError
    }
    
    
    @discardableResult
    func deleteCache(from sut: FeedStoreProtocol) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        
        return deletionError
    }
    
    
    func expect(_ sut: FeedStoreProtocol, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
        
        wait(for: [exp], timeout: 1)
    }
    
    
    func expect(_ sut: FeedStoreProtocol, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
}
