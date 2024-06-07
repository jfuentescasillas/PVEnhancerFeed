//
//  CacheFeedUseCaseTests.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 07/06/2024.
//


import XCTest
import PVEnhancerFeed


class LocalFeedLoader {
    private let store: FeedStoreProtocol
    private let currentDate: () -> Date
    
    
    init(store: FeedStoreProtocol, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    
    func save(_ item: IrradiancesFeed, completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if error == nil {
                self.store.insert(item, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}


protocol FeedStoreProtocol {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ item: IrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion)
}


class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    
    func test_save_requestsCacheDeletion() {
        let item = uniqueItem()
        let (sut, store) = makeSUT()
        
        sut.save(item) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let item = uniqueItem()
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(item) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let item = uniqueItem()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(item) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(item, timestamp)])
    }
    
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var receivedResults = [Error?]()
        
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        sut?.save(uniqueItem()) { receivedResults.append($0) }
        
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        
        sut.save(uniqueItem()) { error in
            receivedError = error
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    
    private class FeedStoreSpy: FeedStoreProtocol {
        enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert(IrradiancesFeed, Date)
        }
        
        
        private(set) var receivedMessages = [ReceivedMessage]()
        
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
        
        
        // Protocol Methods
        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }
        
        
        func insert(_ item: IrradiancesFeed, timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(item, timestamp))
        }
        
        
        // Custom Methods
        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionCompletions[index](error)
        }
        
        
        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionCompletions[index](nil)
        }
        
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }
    
    
    private func uniqueItem() -> IrradiancesFeed {
        let item = IrradiancesFeed(
            geometry: Geometry(
                coordinates: [-3.88, 42.63, 917.61]),
            properties: Properties(
                parameter: Parameter(
                    allskySfcSwDni: [
                        "JAN": 2.38,
                        "FEB": 3.1,
                        "MAR": 3.77,
                        "APR": 4.12,
                        "MAY": 4.94,
                        "JUN": 5.85,
                        "JUL": 6.97,
                        "AUG": 6.31,
                        "SEP": 5.28,
                        "OCT": 3.87,
                        "NOV": 2.62,
                        "DEC": 2.5,
                        "ANN": 4.32
                    ],
                    allskySfcSwDwn: [
                        "JAN": 1.61,
                        "FEB": 2.46,
                        "MAR": 3.73,
                        "APR": 4.87,
                        "MAY": 5.98,
                        "JUN": 6.71,
                        "JUL": 7.06,
                        "AUG": 6.17,
                        "SEP": 4.75,
                        "OCT": 3.1,
                        "NOV": 1.83,
                        "DEC": 1.48,
                        "ANN": 4.16
                    ],
                    allskySfcSwDiff: [
                        "JAN": 0.84,
                        "FEB": 1.2,
                        "MAR": 1.78,
                        "APR": 2.36,
                        "MAY": 2.71,
                        "JUN": 2.73,
                        "JUL": 2.38,
                        "AUG": 2.18,
                        "SEP": 1.82,
                        "OCT": 1.35,
                        "NOV": 0.93,
                        "DEC": 0.74,
                        "ANN": 1.75
                    ]
                )
            )
        )
        
        return item
    }
    
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
