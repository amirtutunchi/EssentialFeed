import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndGet_matchesFixedAccount() {
        let url = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5c52cdd0b8a045df091d2fff/1548930512083/feed-case-study-test-api-feed.json")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: url, client: client)
        var receivedResult: LoadFeedResult?
        let exp = expectation(description: "Wait for execution...")
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        switch receivedResult {
        case let .success(feeds)?:
            XCTAssertEqual(feeds.count, 8)
        case let .failure(error)?:
            XCTFail("expected result got \(error)")
        default:
            XCTFail("expected result got \(String(describing: receivedResult))")
        }
    }

}
