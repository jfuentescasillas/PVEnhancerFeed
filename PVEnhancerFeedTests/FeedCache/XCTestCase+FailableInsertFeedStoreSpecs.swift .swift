//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift .swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 17/06/2024.
//


import XCTest
import PVEnhancerFeed


extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert((uniqueIrradiancesFeed().local, Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }
    

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueIrradiancesFeed().local, Date()), to: sut)

        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
}
