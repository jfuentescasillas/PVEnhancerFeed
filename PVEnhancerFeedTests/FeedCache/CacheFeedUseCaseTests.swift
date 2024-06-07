//
//  CacheFeedUseCaseTests.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 07/06/2024.
//


import XCTest
import PVEnhancerFeed


class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    
    func save(_ item: IrradiancesFeed) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            
            if error == nil {
                self.store.insert(item, timestamp: self.currentDate())
            }
        }
    }
}


class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCachedFeedCallCount: Int = 0
    var insertions = [(item: IrradiancesFeed, timestamp: Date)]()
    private var deletionCompletions = [DeletionCompletion]()
    
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    
    func insert(_ item: IrradiancesFeed, timestamp: Date) {
        insertions.append((item, timestamp))
    }
}


class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    
    func test_save_requestsCacheDeletion() {
        let item = uniqueItem()
        let (sut, store) = makeSUT()
        
        sut.save(item)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let item = uniqueItem()
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(item)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let item = uniqueItem()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(item)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.item, item)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }
    
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
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
