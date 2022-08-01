import XCTest
import EssentialFeed

private class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession = .shared) {
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
    
    func test_getFromURL_failedOnError() {
        // Given
        URLProtocolStub.startIntercepting()
        let url = URL(string: "http://a-url.com")!
        let expectedError = NSError(domain: "fake fail error", code: 1, userInfo: nil)
        URLProtocolStub.stubIn(url: url, error: expectedError)
        let sut = URLSessionHTTPClient()
        
        // When
        let exp = expectation(description: "wait for completion")
        sut.get(url: url) { result in
            switch result {
            case let .failure(receivedError as NSError) :
                XCTAssertEqual(expectedError.domain, receivedError.domain)
                XCTAssertEqual(expectedError.code, receivedError.code)
            default:
                XCTFail("this test should fail expected\(expectedError) got \(result) instead")
            }
           
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopIntercepting()
    }
    // MARK: -Helpers
    private class URLProtocolStub: URLProtocol {
        
        struct Stub {
            let error: Error?
        }
        static var stubs = [URL: Stub]()
        
        static func stubIn(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startIntercepting() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopIntercepting() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return stubs[url] != nil
        }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
   
}
