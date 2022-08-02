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
    override func setUp() {
        super.setUp()
        URLProtocolStub.startIntercepting()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopIntercepting()
    }
    
    func test_getFromURL_failedOnError() {
        // Given
        let url = URL(string: "http://a-url.com")!
        let expectedError = NSError(domain: "fake fail error", code: 1, userInfo: nil)
        URLProtocolStub.stubIn(data: nil, response: nil, error: expectedError)
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
    }
    
    func test_getFromURL_performGetRequest() {
        // Given
        let url = URL(string: "http://a-url.com")!
        URLProtocolStub.stubIn(data: nil, response: nil, error: nil)
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(url: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    // MARK: -Helpers
    private class URLProtocolStub: URLProtocol {
        
        struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        static var stub: Stub? = nil
        
        static var requestObserver: ((URLRequest) -> Void)? = nil
        
        static func stubIn(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startIntercepting() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopIntercepting() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            requestObserver = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
        
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
   
}
