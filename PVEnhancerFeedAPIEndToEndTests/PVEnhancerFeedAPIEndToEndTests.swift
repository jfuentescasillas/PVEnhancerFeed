//
//  PVEnhancerFeedAPIEndToEndTests.swift
//  PVEnhancerFeedAPIEndToEndTests
//
//  Created by jfuentescasillas on 05/06/2024.
//


import XCTest
import PVEnhancerFeed


class PVEnhancerAPIEndToEndTests: XCTestCase {    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(item)?:
            XCTAssertEqual(item, expectedIrradiances(), "Expected item to match the fixed test account data")
            
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    
    // MARK: - Helpers
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> LoadIrradiancesFeedResult? {
        let testServerURL = URL(string: "https://power.larc.nasa.gov/api/temporal/climatology/point?latitude=42.63&longitude=-3.88&community=re&parameters=ALLSKY_SFC_SW_DNI,ALLSKY_SFC_SW_DIFF,ALLSKY_SFC_SW_DWN&format=json")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        var receivedResult: LoadIrradiancesFeedResult?
        
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10)
        
        return receivedResult
    }
    
    
    private func expectedIrradiances() -> IrradiancesFeed {
        let irradianceFeed = IrradiancesFeed(
            geometry: Geometry(coordinates: [-3.88, 42.63, 917.61]),
            properties: Properties(parameter: Parameter(
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
                ]))
        )
        
        return irradianceFeed
    }
}
