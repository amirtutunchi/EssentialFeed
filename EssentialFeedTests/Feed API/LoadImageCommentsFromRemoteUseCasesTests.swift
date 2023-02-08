import XCTest
import EssentialFeed

class LoadImageCommentsFromRemoteUseCasesTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.loadFeed { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.loadFeed { _ in }
        sut.loadFeed { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(feedLoader: sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let samples = [199, 150, 404, 400, 500]
        let (sut, client) = makeSUT()
        samples.enumerated().forEach { index, code in
            expect(feedLoader: sut, toCompleteWithResult: failure(.invalidData)) {
                let jsonData = makeItemJSON([])
                client.complete(withStatusCode: code, data: jsonData, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJson() {
        let samples = [200, 201, 230, 299]
        let (sut, client) = makeSUT()
        samples.enumerated().forEach { index, code in
            expect(feedLoader: sut, toCompleteWithResult: failure(.invalidData)) {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            }
        }
    }
    
    func test_load_deliversEmptyJSONOn2xxHTTPResponse() {
        let samples = [200, 201, 230, 299]
        let (sut, client) = makeSUT()
        samples.enumerated().forEach { index, code in
            expect(feedLoader: sut, toCompleteWithResult: .success([])) {
                let emptyListJSON = Data("{\"items\": []}".utf8)
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            }
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        let feedItem1 = makeFeedItem(
            id: UUID(),
            description: "a description",
            location: "a lcoation",
            imageURL: URL(string: "https://a-given-url.com")!
        )
        
        let feedItem2 = makeFeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://a-given-url.com")!
        )
        let samples = [200, 201, 230, 299]
        samples.enumerated().forEach { index, code in
            expect(
                feedLoader: sut,
                toCompleteWithResult: .success([feedItem1.model, feedItem2.model])
            ) {
                let json = makeItemJSON([feedItem1.json, feedItem2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceDeallocated() {
        // Given
        var sut: RemoteImageCommentLoader?
        let url = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        sut = RemoteImageCommentLoader(url: url, client: client)
        
        // When
        var capturedResult = [RemoteImageCommentLoader.Result]()
        sut?.loadFeed {
            capturedResult.append($0)
        }
        sut = nil

        // Then
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        XCTAssertTrue(capturedResult.isEmpty, "Should not deliver results after deallocation.")
    }
}

// MARK: - Helpers
extension LoadImageCommentsFromRemoteUseCasesTests {
    
    private func makeSUT(
        url: URL = URL(string: "https://a-given-url.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, client: client)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        addTrackForMemoryLeak(object: client,file: file, line: line )
        return (sut, client)
    }

    private func expect(
        feedLoader sut: RemoteImageCommentLoader,
        toCompleteWithResult expectedResult: RemoteImageCommentLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = expectation(description: "Wait for the load")
        sut.loadFeed { receivedResult in
            switch(receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItem)):
                XCTAssertEqual(receivedItems, expectedItem, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentLoader.Error), .failure(expectedError as RemoteImageCommentLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("expected\(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        action()
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func makeFeedItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let feedItem1 = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL
        )
        
        let jsonFeedItem1 = [
            "id": feedItem1.id.uuidString,
            "description": feedItem1.description,
            "location": feedItem1.location,
            "image": feedItem1.url.absoluteString
        ].compactMapValues { $0 }
        
        return (feedItem1, jsonFeedItem1)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteImageCommentLoader.Error) -> RemoteImageCommentLoader.Result {
        .failure(error)
    }
}
