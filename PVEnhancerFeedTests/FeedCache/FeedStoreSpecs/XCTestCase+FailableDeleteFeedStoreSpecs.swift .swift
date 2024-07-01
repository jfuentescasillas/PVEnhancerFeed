//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift .swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 17/06/2024.
//


import XCTest
import PVEnhancerFeed


extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }

    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
