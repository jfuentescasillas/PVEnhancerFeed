//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift .swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 17/06/2024.
//


import XCTest
import PVEnhancerFeed


extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }

    
    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStoreProtocol, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
