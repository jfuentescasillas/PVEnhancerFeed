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
    
    
    init(store: FeedStore) {
        self.store = store
    }
    
    
    func save(_ item: IrradiancesFeed) {
        store.deleteCachedFeed()
    }
}


class FeedStore {
    var deleteCachedFeedCallCount: Int = 0
    
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
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
    
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
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
    

}
