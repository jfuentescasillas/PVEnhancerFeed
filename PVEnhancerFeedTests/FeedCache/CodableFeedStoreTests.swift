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
    func retrieve(completion: @escaping FeedStoreProtocol.RetrievalCompletion) {
        completion(.empty)
    }
}


// MARK: - Class CodableFeedStoreTests
class CodableFeedStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { result in
            switch result {
            case .empty:
                break

            default:
                XCTFail("Expected empty result, got \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

}
