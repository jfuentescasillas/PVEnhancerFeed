//
//  PVEnhancerRemoteFeedLoaderTests.swift
//  PVEnhancerFeedTests
//
//  Created by jfuentescasillas on 23/04/24.
//


import XCTest
import PVEnhancerFeed


// MARK: - PVEnhancerRemoteFeedLoaderTests Class
final class PVEnhancerRemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples: [Int] = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, completeWith: .failure(.invalidData), when: {
                let json = makeItemsJSON(withItem: [:])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            coordinates: [-3.88, 42.63, 917.61],
            dni: [
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
            ghi: [
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
            dhi: [
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
        
        expect(sut, completeWith: .success(item1.model), when: {
            let json = makeItemsJSON(withItem: item1.json)
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    
    /* // NOTE: SINCE THE API ALWAYS DELIVERS ITEMS ON A 200 RESPONSE, THIS TEST IS NOT NEEDED. THERE ARE NO RESPONSES SUCH AS 201, 204, 205,...,299, ETC.
     func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
     let (sut, client) = makeSUT()
     var capturedResults = [RemoteFeedLoader.Result]()
     sut.load { capturedResults.append($0) }
     
     let emptyListJSON = Data("{\"properties\": []}".utf8)
     client.complete(withStatusCode: 200, data: emptyListJSON)
     
     XCTAssertEqual(capturedResults, [.success([])])
     } */
    
    
    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    
    private func makeItem(coordinates: [Double], dni: [String: Double], ghi: [String: Double], dhi: [String: Double]) -> (model: IrradiancesFeed, json: [String: Any]) {
        let geometry = Geometry(coordinates: coordinates)
        let parameter = Parameter(allskySfcSwDni: dni, allskySfcSwDwn: ghi, allskySfcSwDiff: dhi)
        let properties = Properties(parameter: parameter)
        let item = IrradiancesFeed(geometry: geometry, properties: properties)
        
        let json: [String: Any] = [
            "geometry": [
                "type": "Point",
                "coordinates": coordinates
            ],
            "properties": [
                "parameter": [
                    "ALLSKY_SFC_SW_DNI": dni, // Direct Normal Irradiance
                    "ALLSKY_SFC_SW_DWN": ghi, // Global Horizontal Irradiance
                    "ALLSKY_SFC_SW_DIFF": dhi // Diffuse Horizontal Irradiance
                ]
            ]
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    
    private func makeItemsJSON(withItem: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: withItem)
    }
    
    
    private func expect(_ sut : RemoteFeedLoader, completeWith result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    
    private class HTTPClientSpy: HTTPClientProtocol {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
}
