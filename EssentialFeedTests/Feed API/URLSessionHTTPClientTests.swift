import XCTest

private class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_resumeDataTaskCorrectly() {
        // Given
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stubIn(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        // When
        sut.get(url: url)
        
        // Then
        XCTAssertEqual(task.resumeCount, 1)
    }
    // MARK: -Helpers
    
    private class URLSessionSpy: URLSession {
        var stubs = [URL: URLSessionDataTask]()
        func stubIn(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? URLSessionDataTaskSpy()
        }
    }
    private class FakeSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCount = 0
        override func resume() {
            resumeCount += 1
        }
    }
}
