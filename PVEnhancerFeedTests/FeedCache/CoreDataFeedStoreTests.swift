//
//  CoreDataFeedStoreTests.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 17/06/2024.
//


import XCTest
import PVEnhancerFeed


class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }

    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() throws {
        let sut = try makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() throws {
        let sut = try makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    
    func test_insert_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    

    func test_insert_deliversNoErrorOnNonEmptyCache() throws {
        let sut = try makeSUT()
                
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    

    func test_insert_overridesPreviouslyInsertedCacheValues() throws {
        let sut = try makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    
    func test_delete_deliversNoErrorOnEmptyCache() throws {
        let sut = try makeSUT()

        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }

    
    func test_delete_hasNoSideEffectsOnEmptyCache() throws {

    }

    
    func test_delete_deliversNoErrorOnNonEmptyCache() throws {

    }
    

    func test_delete_emptiesPreviouslyInsertedCache() throws {

    }

    
    func test_storeSideEffects_runSerially() throws {

    }
    
    
    // - MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) throws -> FeedStoreProtocol {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        
        trackForMemoryLeaks(sut, file: file, line: line)
    
        return sut
    }
}
