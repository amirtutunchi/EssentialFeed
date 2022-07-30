import XCTest

private class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_createDataTaskFromURL() {
        // Given
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        // When
        sut.get(url: url)
        
        // Then
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    // MARK: -Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return URLSessionDataTaskSpy()
        }
    }

    private class URLSessionDataTaskSpy: URLSessionDataTask { }
}
