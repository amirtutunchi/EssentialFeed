import XCTest
import EssentialFeed

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
        let receivedError = NSError(domain: "fake fail error", code: 1, userInfo: nil)
        let expectedError = resultErrorFor(data: nil, response: nil, error: receivedError) as? NSError
        XCTAssertEqual(expectedError?.domain, receivedError.domain)
        XCTAssertEqual(expectedError?.code, receivedError.code)
    }
    
    func test_getFromURL_performGetRequest() {
        // Given
        let url = anyURL()
        URLProtocolStub.stubIn(data: nil, response: nil, error: nil)
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(url: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_successPath() {
        let expectedData = anyData()
        let expectedResponse = anyHTTPURLResponse()
        let (data, response) = resultDataFor(data: expectedData, response: expectedResponse, error: nil)!
        XCTAssertEqual(data, expectedData)
        XCTAssertEqual(response.url, expectedResponse?.url)
        XCTAssertEqual(response.statusCode, expectedResponse?.statusCode)
    }
    
    func test_getFromURL_successOnNil() {
        let expectedResponse = anyHTTPURLResponse()
        let (data, response) = resultDataFor(data: nil, response: expectedResponse, error: nil)!
        let emptyData = Data()
        XCTAssertEqual(data, emptyData)
        XCTAssertEqual(response.url, expectedResponse?.url)
        XCTAssertEqual(response.statusCode, expectedResponse?.statusCode)
    }
    
    // MARK: -Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
    private func anyData() -> Data {
        Data("any Data".utf8)
    }
    private func anyError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    private func anyHTTPURLResponse() -> HTTPURLResponse? {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        var receivedError: Error?
        switch result {
        case let .failure(error) :
            receivedError = error
        default:
            XCTFail("this test should fail got \(String(describing: result)) instead", file: file, line: line)
        }
        return receivedError
    }
    
    private func resultDataFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (Data, HTTPURLResponse)? {
        // Given
        let result = resultFor(data: data, response: response, error: error)
        var receivedResult: (Data, HTTPURLResponse)?
        switch result {
        case let .success(data, response) :
            receivedResult = (data, response)
        default:
            XCTFail("this test should success got \(String(describing: result)) instead", file: file, line: line)
        }
        return receivedResult
    }
    
    private func resultFor(data: Data?,
                           response: URLResponse?,
                           error: Error?,
                           file: StaticString = #file,
                           line: UInt = #line
    ) -> HTTPClientResult? {
        // Given
        URLProtocolStub.stubIn(data: data, response: response, error: error)
        var receivedResult: HTTPClientResult?
        // When
        let exp = expectation(description: "wait for completion")
        makeSUT(file: file, line: line).get(url: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
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
