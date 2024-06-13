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
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        sut.validateCache()
        store.completeRetrieval(with: uniqueIrradiancesFeed().local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    
    private func uniqueIrradiancesFeed() -> (model: IrradiancesFeed, local: LocalIrradiancesFeed) {
        let modelIrradiances = IrradiancesFeed(
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
        
        let localIrradiances = LocalIrradiancesFeed(
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
        
        return (modelIrradiances, localIrradiances)
    }
    
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}


// MARK: - Extension. Date.
private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
