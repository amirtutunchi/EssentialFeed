import XCTest
import EssentialFeed

private class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL, completionHandler: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completionHandler(.failure(error))
            }
        }.resume()
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
        sut.get(url: url) { _ in }
        
        // Then
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_getFromURL_failedOnError() {
        // Given
        let url = URL(string: "http://a-url.com")!
        let session = URLSessionSpy()
        let expectedError = NSError(domain: "fake fail error", code: 1)
        session.stubIn(url: url, error: expectedError)
        let sut = URLSessionHTTPClient(session: session)
        
        // When
        let exp = expectation(description: "wait for completion")
        sut.get(url: url) { result in
            switch result {
            case let .failure(receivedError) :
                XCTAssertEqual(expectedError, receivedError as NSError)
            default:
                XCTFail("this test should fail expected\(expectedError) got \(result) instead")
            }
           
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)        
    }
    // MARK: -Helpers
    private class URLSessionSpy: URLSession {
        
        struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        var stubs = [URL: Stub]()
        
        func stubIn(url: URL, task: URLSessionDataTask = URLSessionDataTaskSpy(), error: Error? = nil) {
            let stub = Stub(task: task, error: error)
            stubs[url] = stub
        }
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub")
            }
            completionHandler(nil, nil, stub.error)
            return stubs[url]?.task ?? URLSessionDataTaskSpy()
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
