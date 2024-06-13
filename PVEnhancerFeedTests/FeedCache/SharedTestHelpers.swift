//
//  SharedTestHelpers.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 13/06/2024.
//


import Foundation


func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}


func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
