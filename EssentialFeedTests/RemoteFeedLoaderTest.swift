@testable import EssentialFeed
import XCTest

class RemoteFeedLoaderTest: XCTestCase {
    func test_init() {
        let (_, client) = makeSUT()
        XCTAssertNil(client.requestedURL)
    }
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        func get(from url: URL) {
            requestedURL = url
        }
        var requestedURL: URL?
    }
}
