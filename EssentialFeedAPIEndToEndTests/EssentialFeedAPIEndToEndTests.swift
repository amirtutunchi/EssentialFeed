import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndGet_matchesFixedAccount() {
        switch getFeedResult() {
        case let .success(feeds)?:
            XCTAssertEqual(feeds.count, 8)
        case let .failure(error)?:
            XCTFail("expected result got \(error)")
        default:
            XCTFail("expected result got nothing")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
            switch getFeedImageDataResult() {
            case let .success(data)?:
                XCTAssertFalse(data.isEmpty, "Expected non-empty image data")

            case let .failure(error)?:
                XCTFail("Expected successful image data result, got \(error) instead")

            default:
                XCTFail("Expected successful image data result, got no result instead")
            }
        }
    
    //MARK: - Helpers:
    
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> FeedLoader.Result? {
        let loader = RemoteFeedLoader(url: feedTestServerURL, client: ephemeralClient())
        var receivedResult: FeedLoader.Result?
        addTrackForMemoryLeak(object: loader)
        let exp = expectation(description: "Wait for execution...")
        loader.loadFeed { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let loader = RemoteFeedImageDataLoader(client: ephemeralClient())
        addTrackForMemoryLeak(object: loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        let url = feedTestServerURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        
        var receivedResult: FeedImageDataLoader.Result?
        _ = loader.loadImage(from: url) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private var feedTestServerURL: URL {
        return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        addTrackForMemoryLeak(object: client, file: file, line: line)
        return client
    }
}
