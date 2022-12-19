import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    
//    func test_getFromURL_failedOnError() {
//        // Given
//        let requestError = anyError()
//        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))
//        XCTAssertEqual(receivedError as NSError?, requestError)
//     
//    }
    
    func test_getFromURL_performGetRequest() {
        // Given
        let url = anyURL()
        let exp = expectation(description: "wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { _ in exp.fulfill() }
        
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
        wait(for: [exp], timeout: 7.0)
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    func test_getFromURL_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_getFromURL_successPath() {
        let expectedData = anyData()
        let expectedResponse = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor((data: expectedData, response: expectedResponse, error: nil))
        
        XCTAssertEqual(receivedValues?.data, expectedData)
        XCTAssertEqual(receivedValues?.response.url, expectedResponse?.url)
    }
    
    func test_getFromURL_successOnNil() {
        let expectedResponse = anyHTTPURLResponse()
        let response = resultValuesFor((data: nil, response: expectedResponse, error: nil))
        let emptyData = Data()
        XCTAssertEqual(response?.data, emptyData)
        XCTAssertEqual(response?.response.url, expectedResponse?.url)
        XCTAssertEqual(response?.response.statusCode, expectedResponse?.statusCode)
    }
    
    // MARK: -Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        addTrackForMemoryLeak(object: sut, file: file, line: line)
        return sut
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse? {
        HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> Error? {
            let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        var receivedError: Error?
        switch result {
        case let .failure(error) :
            receivedError = error
        default:
            XCTFail("this test should fail got \(String(describing: result)) instead", file: file, line: line)
        }
        return receivedError
    }
    
    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)

        var receivedResult: (Data, HTTPURLResponse)?
        switch result {
        case let .success((data, response)) :
            receivedResult = (data, response)
        default:
            XCTFail("this test should success got \(String(describing: result)) instead", file: file, line: line)
        }
        return receivedResult
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },  file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
            values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        var receivedResult: HTTPClient.Result?
        // When
        let exp = expectation(description: "wait for completion")
        let sut = makeSUT(file: file, line: line)
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return receivedResult!
    }
}
